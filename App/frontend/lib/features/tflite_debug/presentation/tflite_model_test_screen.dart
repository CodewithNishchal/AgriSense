import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/ml/tflite_helper.dart';
import '../../disease_detection/data/label_mapping.dart';
import '../../disease_detection/data/plant_village_labels.dart';
import '../intelligence_report_builder.dart';
import 'intelligence_report_panel.dart';

/// Pick image → TFLite → raw tensors + Colab-style Layer 2 intelligence report.
class TfliteModelTestScreen extends StatefulWidget {
  const TfliteModelTestScreen({super.key});

  @override
  State<TfliteModelTestScreen> createState() => _TfliteModelTestScreenState();
}

class _TfliteModelTestScreenState extends State<TfliteModelTestScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _file;
  bool _loading = false;
  String _log = 'Pick an image, then tap Run model.\n';
  String? _modelStatus;
  Map<String, dynamic>? _intelligenceReport;
  String? _protocolsStatus;

  @override
  void initState() {
    super.initState();
    _primeModel();
  }

  Future<void> _primeModel() async {
    await TFLiteHelper.instance.ensureInitialized();
    if (!mounted) return;
    final err = TFLiteHelper.instance.loadError;
    setState(() {
      _modelStatus = err == null ? 'Model asset loaded OK.' : err;
    });
    try {
      await IntelligenceReportBuilder.ensureLoaded();
      if (!mounted) return;
      setState(() => _protocolsStatus = 'Protocols JSON loaded OK.');
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _protocolsStatus = 'Protocols load failed: $e');
      // ignore: avoid_print
      print('Protocols: $e\n$st');
    }
  }

  Future<void> _pick(ImageSource source) async {
    final x = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 90,
    );
    if (x == null || !mounted) return;
    setState(() {
      _file = File(x.path);
      _log = 'Image: ${x.path}\nTap Run model.\n';
      _intelligenceReport = null;
    });
  }

  Future<void> _run() async {
    final f = _file;
    if (f == null) {
      setState(() => _log = 'Pick an image first.\n');
      return;
    }
    setState(() {
      _loading = true;
      _log = 'Running…\n';
      _intelligenceReport = null;
    });
    final result = await TFLiteHelper.instance.analyzeImageDebug(f);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result == null) {
      final err = TFLiteHelper.instance.describeFailure();
      // ignore: avoid_print
      print('\n======== TFLite error (copy from terminal) ========\n$err\n======== end ========\n');
      setState(() => _log = err);
      return;
    }

    final idx = result['index'] as int;
    final conf = result['confidence'];
    final raw = result['raw_output'] as List<double>;
    final inSh = result['input_shape'] as List<dynamic>;
    final outSh = result['output_shape'] as List<dynamic>;

    final label = (idx >= 0 && idx < kPlantVillage38ClassLabels.length)
        ? kPlantVillage38ClassLabels[idx]
        : '(no label at index)';
    final readable = formatPlantVillageLabelKey(label);

    final jsonBlock = const JsonEncoder.withIndent('  ').convert({
      'index': idx,
      'confidence': conf,
      'raw_output': raw,
      'input_shape': inSh,
      'output_shape': outSh,
      'label_key': label,
    });

    final summary = StringBuffer()
      ..writeln('=== Argmax ===')
      ..writeln('index: $idx')
      ..writeln('value at index: $conf')
      ..writeln('label key: $label')
      ..writeln('readable: $readable')
      ..writeln()
      ..writeln('input_shape: $inSh')
      ..writeln('output_shape: $outSh')
      ..writeln()
      ..writeln('=== raw_output (${raw.length} floats) ===')
      ..writeln(raw.map((e) => e.toStringAsFixed(6)).join(', '))
      ..writeln()
      ..writeln('=== JSON (raw_output as list) ===')
      ..writeln(jsonBlock);

    final fullLog = summary.toString();
    // ignore: avoid_print
    print('\n======== TFLite output (copy from terminal) ========\n'
        '$fullLog\n'
        '======== end TFLite output ========\n');

    Map<String, dynamic>? intel;
    if (!label.startsWith('(')) {
      try {
        await IntelligenceReportBuilder.ensureLoaded();
        intel = await IntelligenceReportBuilder.build(
          diseaseKey: label,
          confidenceRaw: (conf as num).toDouble(),
          rawOutput: raw,
          topK: 3,
        );
        final intelJson =
            const JsonEncoder.withIndent('  ').convert(intel);
        // ignore: avoid_print
        print('\n======== Intelligence report JSON (copy from terminal) ========\n'
            '$intelJson\n'
            '======== end intelligence JSON ========\n');
      } catch (e, st) {
        intel = null;
        // ignore: avoid_print
        print('IntelligenceReportBuilder failed: $e\n$st');
      }
    }

    if (!mounted) return;
    setState(() {
      _log = fullLog;
      _intelligenceReport = intel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TFLite + intelligence'),
          backgroundColor: Colors.black87,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Raw output'),
              Tab(text: 'Intelligence report'),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_modelStatus != null)
              Material(
                color: TFLiteHelper.instance.loadError != null
                    ? Colors.red.shade900
                    : Colors.green.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    _modelStatus!,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            if (_protocolsStatus != null)
              Material(
                color: _protocolsStatus!.contains('failed')
                    ? Colors.orange.shade900
                    : Colors.blueGrey.shade800,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Text(
                    _protocolsStatus!,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed:
                        _loading ? null : () => _pick(ImageSource.gallery),
                    child: const Text('Gallery'),
                  ),
                  FilledButton(
                    onPressed:
                        _loading ? null : () => _pick(ImageSource.camera),
                    child: const Text('Camera'),
                  ),
                  FilledButton.tonal(
                    onPressed: _loading ? null : _run,
                    child: Text(_loading ? '…' : 'Run model'),
                  ),
                ],
              ),
            ),
            if (_file != null)
              SizedBox(
                height: 140,
                child: Image.file(_file!, fit: BoxFit.contain),
              ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  SelectionArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _log,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  _intelligenceReport == null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Run the model on an image. The Colab-style report '
                              'appears here (needs assets/data/disease_protocols.json).',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                        )
                      : IntelligenceReportPanel(
                          report: _intelligenceReport!,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
