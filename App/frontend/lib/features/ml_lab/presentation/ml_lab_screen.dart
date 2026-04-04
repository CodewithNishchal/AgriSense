import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/location/location_helper.dart';
import '../../../core/network/app_config.dart';
import '../../../core/network/crop_disease_api_service.dart'
    show CropDiseaseApiService, createCropDiseaseDio;
import '../../../core/network/disease_diagnosis_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

String _absoluteBackendUrl(String? pathOrUrl) {
  if (pathOrUrl == null || pathOrUrl.isEmpty) return '';
  final p = pathOrUrl.trim();
  if (p.startsWith('http://') || p.startsWith('https://')) return p;
  return '$kBaseUrl$p';
}

/// Dev screen: image + optional mic → STT, optional STT+TTS pipeline, predict.
class MlLabScreen extends StatefulWidget {
  const MlLabScreen({super.key});

  @override
  State<MlLabScreen> createState() => _MlLabScreenState();
}

class _MlLabScreenState extends State<MlLabScreen> {
  final CropDiseaseApiService _api = CropDiseaseApiService();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _transcript = TextEditingController();

  StreamSubscription<void>? _playerCompleteSub;

  String? _imagePath;
  String? _audioPath;
  bool _recording = false;
  bool _busy = false;
  bool _pipelineBusy = false;
  bool _playingInput = false;
  bool _playingTts = false;
  bool _ttsLoadBusy = false;
  bool _downloadingTts = false;
  bool _sharingTts = false;
  String? _ttsMimeType;
  Map<String, dynamic>? _lastPredict;
  Map<String, dynamic>? _lastStt;
  Map<String, dynamic>? _lastPipeline;
  String? _ttsAudioUrl;
  bool _geminiBusy = false;
  String? _lastGeminiReply;
  Map<String, dynamic>? _lastGeminiRaw;

  @override
  void initState() {
    super.initState();
    _playerCompleteSub = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playingInput = false;
        _playingTts = false;
      });
    });
  }

  @override
  void dispose() {
    _playerCompleteSub?.cancel();
    _player.dispose();
    _transcript.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _stopPlayback() async {
    await _player.stop();
    if (mounted) {
      setState(() {
        _playingInput = false;
        _playingTts = false;
        _ttsLoadBusy = false;
      });
    }
  }

  String? _mimeForTtsPlayback(String urlLower) {
    final from = _ttsMimeType?.split(';').first.trim();
    if (from != null && from.isNotEmpty) return from;
    if (urlLower.endsWith('.wav')) return 'audio/wav';
    if (urlLower.endsWith('.mp3')) return 'audio/mpeg';
    return 'audio/mpeg';
  }

  Future<void> _togglePlayRecording() async {
    final p = _audioPath;
    if (p == null || !File(p).existsSync() || _recording) {
      if (_recording) _toast('Stop recording first.');
      return;
    }
    if (_playingInput) {
      await _stopPlayback();
      return;
    }
    await _stopPlayback();
    try {
      await _player.play(DeviceFileSource(p));
      if (mounted) setState(() => _playingInput = true);
    } catch (e) {
      _toast('Playback failed: $e');
    }
  }

  Future<void> _playTtsResponse() async {
    final url = _ttsAudioUrl;
    if (url == null || url.isEmpty) {
      _toast('Run STT + TTS pipeline first (needs Sarvam for speech output).');
      return;
    }
    if (_playingTts || _ttsLoadBusy) {
      await _stopPlayback();
      return;
    }
    await _stopPlayback();
    final urlLower = url.toLowerCase();
    final ext = urlLower.endsWith('.wav') ? '.wav' : '.mp3';
    final mime = _mimeForTtsPlayback(urlLower);

    setState(() => _ttsLoadBusy = true);
    try {
      final dir = await getTemporaryDirectory();
      final localPath = '${dir.path}/ml_lab_tts_play$ext';
      final dio = createCropDiseaseDio();
      await dio.download(url, localPath);

      if (!File(localPath).existsSync() || File(localPath).lengthSync() == 0) {
        throw StateError('Downloaded file missing or empty');
      }

      await _player.play(DeviceFileSource(localPath, mimeType: mime));
      if (!mounted) return;
      setState(() {
        _ttsLoadBusy = false;
        _playingTts = true;
      });
    } catch (e, st) {
      debugPrint('TTS play: $e\n$st');
      if (mounted) {
        setState(() {
          _ttsLoadBusy = false;
          _playingTts = false;
        });
      }
      _toast('TTS playback failed: $e');
    }
  }

  Future<void> _downloadTtsResponse() async {
    final url = _ttsAudioUrl;
    if (url == null || url.isEmpty) {
      _toast('No response audio URL. Run the pipeline with Sarvam TTS first.');
      return;
    }
    setState(() => _downloadingTts = true);
    try {
      final uri = Uri.parse(url);
      var baseName = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'tts_response.wav';
      if (!baseName.contains('.')) {
        baseName = '$baseName.wav';
      }
      final safe =
          baseName.replaceAll(RegExp(r'[^A-Za-z0-9._\-]'), '_');
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/ml_lab_${DateTime.now().millisecondsSinceEpoch}_$safe';

      final dio = createCropDiseaseDio();
      await dio.download(url, path);

      if (!mounted) return;
      setState(() => _downloadingTts = false);
      _toast('Saved:\n$path');
    } catch (e) {
      if (!mounted) return;
      setState(() => _downloadingTts = false);
      _toast('Download failed: $e');
    }
  }

  Future<void> _shareTtsResponse() async {
    final url = _ttsAudioUrl;
    if (url == null || url.isEmpty) {
      _toast('Run pipeline with TTS first.');
      return;
    }
    setState(() => _sharingTts = true);
    try {
      final dir = await getTemporaryDirectory();
      final urlLower = url.toLowerCase();
      final ext = urlLower.endsWith('.wav') ? '.wav' : '.mp3';
      final path = '${dir.path}/ml_lab_tts_share$ext';
      final dio = createCropDiseaseDio();
      await dio.download(url, path);
      if (!File(path).existsSync() || File(path).lengthSync() == 0) {
        throw StateError('Downloaded file missing or empty');
      }
      final uri = Uri.tryParse(url);
      final shareName = (uri != null && uri.pathSegments.isNotEmpty)
          ? uri.pathSegments.last
          : 'tts_response$ext';
      final mime = _mimeForTtsPlayback(urlLower);
      await Share.shareXFiles(
        [
          XFile(
            path,
            mimeType: mime,
            name: shareName,
          ),
        ],
        subject: 'Crop disease voice response',
        text: 'TTS response from AgriSense API lab',
      );
    } catch (e) {
      _toast('Share failed: $e');
    } finally {
      if (mounted) setState(() => _sharingTts = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final x = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 88,
    );
    if (x == null || !mounted) return;
    setState(() => _imagePath = x.path);
  }

  Future<void> _toggleRecord() async {
    if (_recording) {
      final path = await _recorder.stop();
      if (!mounted) return;
      setState(() {
        _recording = false;
        if (path != null) _audioPath = path;
      });
      return;
    }

    final perm = await Permission.microphone.request();
    if (!perm.isGranted) {
      _toast('Microphone permission is required to record.');
      return;
    }
    if (!await _recorder.hasPermission()) {
      _toast('Recording is not available on this device.');
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/ml_lab_${DateTime.now().millisecondsSinceEpoch}.wav';

    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 128000,
        ),
        path: path,
      );
      if (!mounted) return;
      setState(() {
        _recording = true;
        _audioPath = path;
      });
    } catch (e) {
      _toast('Could not start recording: $e');
    }
  }

  Future<void> _runStt() async {
    final path = _audioPath;
    if (path == null || path.isEmpty) {
      _toast('Record audio first (or recording may still be in progress).');
      return;
    }
    if (_recording) {
      _toast('Stop recording before transcribing.');
      return;
    }
    if (!File(path).existsSync()) {
      _toast('Audio file missing. Record again.');
      return;
    }

    setState(() => _busy = true);
    try {
      final data = await _api.transcribeAudio(audioPath: path, mode: 'auto');
      if (!mounted) return;
      setState(() {
        _busy = false;
        _lastStt = data;
        final t = data['transcript']?.toString().trim() ?? '';
        if (t.isNotEmpty) _transcript.text = t;
      });
      if (data['error'] != null &&
          data['error'].toString().isNotEmpty) {
        _toast('STT: ${data['error']}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast(CropDiseaseApiService.dioErrorMessage(e));
    }
  }

  Future<void> _runVoicePipeline() async {
    final path = _audioPath;
    if (path == null || !File(path).existsSync()) {
      _toast('Record audio first.');
      return;
    }
    if (_recording) {
      _toast('Stop recording before running the pipeline.');
      return;
    }

    setState(() {
      _pipelineBusy = true;
      _lastPipeline = null;
      _ttsAudioUrl = null;
      _ttsMimeType = null;
    });
    try {
      final data = await _api.voicePipeline(audioPath: path, mode: 'auto');
      if (!mounted) return;
      final rel = data['audio_download_url']?.toString();
      final absolute = _absoluteBackendUrl(rel);
      String? mime;
      final tts = data['tts'];
      if (tts is Map) {
        mime = tts['mime_type']?.toString();
      }
      setState(() {
        _pipelineBusy = false;
        _lastPipeline = data;
        _ttsAudioUrl = absolute.isNotEmpty ? absolute : null;
        _ttsMimeType = mime;
        final t = data['transcript']?.toString().trim() ?? '';
        if (t.isNotEmpty) _transcript.text = t;
      });
      if (data['status'] == 'error') {
        final err = data['stt'];
        if (err is Map && err['error'] != null) {
          _toast('Pipeline: ${err['error']}');
        } else if (data['tts'] is Map && (data['tts'] as Map)['error'] != null) {
          _toast('TTS: ${(data['tts'] as Map)['error']}');
        } else {
          _toast('Pipeline finished with errors (see JSON).');
        }
      } else if (_ttsAudioUrl == null) {
        _toast(
          'No TTS file (offline mode skips TTS, or Sarvam not configured). '
          'Transcript is still in the text field.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _pipelineBusy = false);
      _toast(CropDiseaseApiService.dioErrorMessage(e));
    }
  }

  Future<void> _runPredict() async {
    final path = _imagePath;
    if (path == null || !File(path).existsSync()) {
      _toast('Pick a leaf image first.');
      return;
    }

    setState(() => _busy = true);
    try {
      double? lat;
      double? lon;
      try {
        final pos = await LocationHelper.getCurrentPosition();
        lat = pos?.latitude;
        lon = pos?.longitude;
      } catch (_) {}

      final data = await _api.predictLeaf(
        imagePath: path,
        textInput: _transcript.text.trim().isEmpty
            ? null
            : _transcript.text.trim(),
        locationLat: lat,
        locationLon: lon,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _lastPredict = data;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast(CropDiseaseApiService.dioErrorMessage(e));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _toast(e.toString());
    }
  }

  Future<void> _askGeminiWithDisease() async {
    final predict = _lastPredict;
    if (predict == null) {
      _toast('Run disease prediction first (need JSON from /predict).');
      return;
    }
    final q = _transcript.text.trim();
    final audioPath = _audioPath;
    final hasAudio = audioPath != null &&
        !_recording &&
        File(audioPath).existsSync();
    if (q.isEmpty && !hasAudio) {
      _toast('Type a question or keep a recording (audio wins if both sent).');
      return;
    }

    setState(() {
      _geminiBusy = true;
      _lastGeminiReply = null;
      _lastGeminiRaw = null;
    });
    try {
      final data = await _api.chatbotAskWithDisease(
        diseaseJsonString: jsonEncode(predict),
        questionText: q.isNotEmpty ? q : null,
        audioPath: hasAudio ? audioPath : null,
      );
      if (!mounted) return;
      final reply = data['reply']?.toString().trim() ?? '';
      setState(() {
        _geminiBusy = false;
        _lastGeminiRaw = data;
        _lastGeminiReply = reply.isNotEmpty ? reply : null;
      });
      if (reply.isEmpty) {
        _toast('No reply text in response (see JSON).');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _geminiBusy = false;
      });
      _toast(CropDiseaseApiService.dioErrorMessage(e));
    }
  }

  void _openReport() {
    final data = _lastPredict;
    final img = _imagePath;
    if (data == null || img == null) {
      _toast('Run disease prediction first.');
      return;
    }
    final extra = Map<String, dynamic>.from(
      DiseaseDiagnosisService.toResultExtra(data),
    );
    extra['imagePath'] = img;
    extra['fullReport'] = data;
    String? label;
    try {
      final pos = data['location'];
      if (pos is Map && pos['lat'] != null && pos['lon'] != null) {
        label = '${pos['lat']}, ${pos['lon']}';
      }
    } catch (_) {}
    extra['locationLabel'] = label;
    final t = _transcript.text.trim();
    if (t.isNotEmpty) extra['geminiQuestionPrefill'] = t;
    context.push('/disease-result', extra: extra);
  }

  bool get _anyBusy =>
      _busy ||
      _pipelineBusy ||
      _downloadingTts ||
      _ttsLoadBusy ||
      _sharingTts ||
      _geminiBusy;

  @override
  Widget build(BuildContext context) {
    final jsonEncoder = const JsonEncoder.withIndent('  ');
    String? predictPretty;
    String? sttPretty;
    String? pipelinePretty;
    String? geminiPretty;
    try {
      if (_lastPredict != null) predictPretty = jsonEncoder.convert(_lastPredict);
    } catch (_) {}
    try {
      if (_lastStt != null) sttPretty = jsonEncoder.convert(_lastStt);
    } catch (_) {}
    try {
      if (_lastPipeline != null) {
        pipelinePretty = jsonEncoder.convert(_lastPipeline);
      }
    } catch (_) {}
    try {
      if (_lastGeminiRaw != null) {
        geminiPretty = jsonEncoder.convert(_lastGeminiRaw);
      }
    } catch (_) {}

    return EditorialScaffold(
      title: 'API lab',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Text(
            'Backend: $kBaseUrl',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Run crop-disease-prediction on port 8000 (e.g. uvicorn main:app --host 0.0.0.0 --port 8000). '
            'Set BASE_URL or CROP_DISEASE_BASE_URL in assets/.env (or --dart-define) for a physical device on your LAN.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            '1. Leaf image',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _anyBusy ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _anyBusy ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                ),
              ),
            ],
          ),
          if (_imagePath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_imagePath!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            '2. Voice (optional)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _anyBusy ? null : _toggleRecord,
                  icon: Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded),
                  label: Text(_recording ? 'Stop' : 'Record'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _anyBusy ? null : _runStt,
                  child: const Text('Transcribe'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (_audioPath == null ||
                          _recording ||
                          !File(_audioPath ?? '').existsSync() ||
                          _anyBusy)
                      ? null
                      : _togglePlayRecording,
                  icon: Icon(_playingInput ? Icons.stop_rounded : Icons.volume_up_rounded),
                  label: Text(_playingInput ? 'Stop playback' : 'Play recording'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _anyBusy ? null : _stopPlayback,
                  child: const Text('Stop sound'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _pipelineBusy ? null : _runVoicePipeline,
            icon: _pipelineBusy
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimaryFixed,
                    ),
                  )
                : const Icon(Icons.graphic_eq_rounded),
            label: Text(
              _pipelineBusy ? 'Pipeline…' : 'STT + TTS (full pipeline)',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimaryFixed,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Pipeline needs Sarvam in the server .env for TTS. Offline STT still runs; TTS may be skipped.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.35,
                  ),
            ),
          ),
          if (_ttsAudioUrl != null) ...[
            const SizedBox(height: 12),
            Text(
              'TTS response',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (_pipelineBusy ||
                            _busy ||
                            _downloadingTts ||
                            _ttsLoadBusy)
                        ? null
                        : _playTtsResponse,
                    icon: _ttsLoadBusy
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimaryFixed,
                            ),
                          )
                        : Icon(
                            _playingTts ? Icons.stop_rounded : Icons.play_arrow_rounded,
                          ),
                    label: Text(
                      _ttsLoadBusy
                          ? 'Loading…'
                          : (_playingTts ? 'Stop' : 'Play response'),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimaryFixed,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (_pipelineBusy || _busy || _downloadingTts)
                        ? null
                        : _downloadTtsResponse,
                    icon: _downloadingTts
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(Icons.download_rounded),
                    label: Text(_downloadingTts ? 'Saving…' : 'Download'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: (_pipelineBusy ||
                        _busy ||
                        _downloadingTts ||
                        _ttsLoadBusy ||
                        _sharingTts)
                    ? null
                    : _shareTtsResponse,
                icon: _sharingTts
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(Icons.share_rounded),
                label: Text(_sharingTts ? 'Preparing…' : 'Share audio'),
              ),
            ),
          ],
          if (_audioPath != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Audio: ${_audioPath!.split(Platform.pathSeparator).last}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _transcript,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Speech text (filled by STT or type manually)',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          if (sttPretty != null) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              title: const Text('Last STT response (JSON)'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    sttPretty,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (pipelinePretty != null) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              title: const Text('Last pipeline response (JSON)'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    pipelinePretty,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Text(
            '3. Disease prediction',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _anyBusy ? null : _runPredict,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimaryFixed,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_busy) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimaryFixed,
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  const Icon(Icons.science_outlined),
                  const SizedBox(width: 8),
                ],
                Text(_busy ? 'Working…' : 'POST /api/v1/predict'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: (_lastPredict == null || _imagePath == null)
                ? null
                : _openReport,
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open as disease report'),
          ),
          if (predictPretty != null) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              initiallyExpanded: true,
              title: const Text('Predict response (JSON)'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    predictPretty,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Text(
            '4. Ask Gemini (predict JSON + question)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Server uses GEMINI_API_KEY from crop-disease-prediction/.env. '
            'Sends last /predict JSON plus your text field and/or recording; '
            'if both are sent, the server transcribes audio and uses that question.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: (_lastPredict == null || _geminiBusy || _recording)
                ? null
                : _askGeminiWithDisease,
            icon: _geminiBusy
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimaryFixed,
                    ),
                  )
                : const Icon(Icons.smart_toy_outlined),
            label: Text(
              _geminiBusy ? 'Asking…' : 'POST /chatbot/ask-with-disease',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimaryFixed,
            ),
          ),
          if (_lastGeminiReply != null) ...[
            const SizedBox(height: 12),
            Text(
              'Gemini reply',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            SelectableText(
              _lastGeminiReply!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                  ),
            ),
          ],
          if (geminiPretty != null) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              title: const Text('Last Gemini API response (JSON)'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    geminiPretty,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
