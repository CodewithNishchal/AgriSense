import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/location/location_helper.dart';
import '../../../core/ml/tflite_helper.dart';
import '../../../core/network/app_config.dart';
import '../../../core/network/crop_disease_reachability.dart';
import '../../../core/network/disease_diagnosis_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';
import '../../disease_detection/data/disease_data.dart';
import '../../disease_detection/data/plant_village_labels.dart';
import '../../tflite_debug/intelligence_report_builder.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();

  StreamSubscription<List<ConnectivityResult>>? _connSub;

  bool _loading = false;
  bool _probingReachability = false;
  bool _backendReachable = false;

  static const double _kMinConfidence = 0.40;

  bool get _useCloudPredict => !kUseMockData && _backendReachable;

  Future<({double? lat, double? lon, String? label})> _readGps() async {
    double? lat;
    double? lon;
    String? label;
    try {
      final pos = await LocationHelper.getCurrentPosition();
      if (pos != null) {
        lat = pos.latitude;
        lon = pos.longitude;
        label = LocationHelper.formatPosition(pos);
      }
    } catch (_) {}
    return (lat: lat, lon: lon, label: label);
  }

  static Map<String, dynamic> _locationJson(
    double? lat,
    double? lon,
    String? locationLabel,
  ) {
    return <String, dynamic>{
      'lat': lat,
      'lon': lon,
      if (locationLabel != null && locationLabel.isNotEmpty) 'label': locationLabel,
    };
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    TFLiteHelper.instance.ensureInitialized();
    IntelligenceReportBuilder.ensureLoaded().catchError((_) {});
    _connSub = Connectivity().onConnectivityChanged.listen((_) {
      _refreshBackendReachable();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshBackendReachable();
    });
  }

  @override
  void dispose() {
    _connSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshBackendReachable();
    }
  }

  Future<void> _refreshBackendReachable() async {
    if (kUseMockData) {
      if (!mounted) return;
      setState(() {
        _backendReachable = false;
        _probingReachability = false;
      });
      return;
    }
    if (!mounted) return;
    setState(() => _probingReachability = true);
    final ok = await isCropDiseaseBackendReachable();
    if (!mounted) return;
    setState(() {
      _probingReachability = false;
      _backendReachable = ok;
    });
  }

  Future<void> _runDiseaseFlow(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 88,
    );
    if (file == null || !mounted) return;
    setState(() => _loading = true);

    final gps = await _readGps();
    final lat = gps.lat;
    final lon = gps.lon;
    final locationLabel = gps.label;
    final scanTime = DateFormat('MMM d, yyyy • h:mm a').format(DateTime.now());

    Map<String, dynamic>? extra;

    if (_useCloudPredict) {
      final api = await DiseaseDiagnosisService().diagnoseFromFile(
        imagePath: file.path,
        lat: lat,
        lon: lon,
      );
      if (api != null && mounted) {
        api['scan_time_display'] = scanTime;
        if (locationLabel != null && locationLabel.isNotEmpty) {
          final loc = api['location'];
          if (loc is Map) {
            api['location'] = <String, dynamic>{
              for (final e in loc.entries) e.key.toString(): e.value,
              'label': locationLabel,
            };
          }
        }
        extra = DiseaseDiagnosisService.toResultExtra(api);
      }
    }

    if (extra == null) {
      final tfResult =
          await TFLiteHelper.instance.analyzeImageDebug(File(file.path));

      if (!mounted) return;
      setState(() => _loading = false);

      if (tfResult == null) {
        if (!mounted) return;
        final detail = TFLiteHelper.instance.describeFailure();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(detail, style: const TextStyle(fontSize: 13)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 8),
          ),
        );
        return;
      }

      final confidence = (tfResult['confidence'] as num).toDouble();
      final classIndex = tfResult['index'] as int;
      final rawOutput = tfResult['raw_output'] as List<double>;

      if (classIndex < 0 || classIndex >= kPlantVillage38ClassLabels.length) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Model class index $classIndex is outside 0–${kPlantVillage38ClassLabels.length - 1}. '
              'Check label list vs your .tflite.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (confidence <= _kMinConfidence) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not identify disease confidently. Please retake the photo.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final diseaseKey = kPlantVillage38ClassLabels[classIndex];

      Map<String, dynamic> offlineExtra;
      try {
        await IntelligenceReportBuilder.ensureLoaded();
        final fullReport = await IntelligenceReportBuilder.build(
          diseaseKey: diseaseKey,
          confidenceRaw: confidence,
          rawOutput: rawOutput,
          topK: 3,
          lat: lat,
          lon: lon,
        );
        fullReport['scan_time_display'] = scanTime;
        fullReport['location'] = _locationJson(lat, lon, locationLabel);
        offlineExtra = DiseaseDiagnosisService.toResultExtra(fullReport);
      } catch (_) {
        final fallback = buildOfflineTfliteResultExtra(
          classIndex: classIndex,
          confidenceRaw: confidence,
          imagePath: file.path,
          scanTimeDisplay: scanTime,
          locationLabel: locationLabel,
          lat: lat,
          lon: lon,
        );
        offlineExtra = Map<String, dynamic>.from(fallback);
      }

      extra = offlineExtra;
    }

    if (!mounted) return;
    setState(() => _loading = false);

    extra['imagePath'] = file.path;
    extra['locationLabel'] = locationLabel;

    await context.push<void>('/disease-result', extra: extra);
  }

  String get _statusSubtitle {
    if (kUseMockData) {
      return 'Local-only: on-device analysis only (no disease server).';
    }
    if (_probingReachability) {
      return 'Checking connection to your disease server…';
    }
    if (_backendReachable) {
      return 'Online: leaf photo is sent to your server (POST /predict). '
          'If the server fails, this device falls back to on-device TFLite.';
    }
    return 'Offline or server unreachable: on-device TFLite only. '
        'Connect to the same network as your PC running uvicorn, or tap '
        '“Recheck connection”.';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Scan'),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return EditorialScaffold(
      title: 'Scan',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= AppBreakpoint.md;

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Text(
                'Leaf disease scan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
              if (!kUseMockData) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _probingReachability ? null : _refreshBackendReachable,
                    icon: _probingReachability
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(Icons.wifi_find_rounded, size: 20),
                    label: const Text('Recheck connection'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _ScanLeafCard(
                wide: wide,
                onGallery: () => _runDiseaseFlow(ImageSource.gallery),
                onCamera: () => _runDiseaseFlow(ImageSource.camera),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScanLeafCard extends StatelessWidget {
  const _ScanLeafCard({
    required this.wide,
    required this.onGallery,
    required this.onCamera,
  });

  final bool wide;
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    final row = wide;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Capture leaf',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gallery or camera. GPS is added when location permission is allowed.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ScanActionButton(
                onPressed: onGallery,
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                filled: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ScanActionButton(
                onPressed: onCamera,
                icon: Icons.photo_camera_outlined,
                label: 'Camera',
                filled: true,
              ),
            ),
          ],
        ),
      ],
    );

    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: row ? 24 : 20,
          vertical: 20,
        ),
        child: content,
      ),
    );
  }
}

class _ScanActionButton extends StatelessWidget {
  const _ScanActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.filled,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool filled;

  static const _pad = EdgeInsets.symmetric(horizontal: 8, vertical: 12);
  static const _minSize = Size(0, 44);

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        );

    if (filled) {
      final onCta = AppColors.onPrimaryFixed;
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: _pad,
          minimumSize: _minSize,
          backgroundColor: AppColors.primary,
          foregroundColor: onCta,
          disabledBackgroundColor: AppColors.surfaceContainerHigh,
          disabledForegroundColor: AppColors.onSurfaceMuted,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: onCta),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: labelStyle?.copyWith(color: onCta),
              ),
            ),
          ],
        ),
      );
    }

    final accent = AppColors.primary;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: _pad,
        minimumSize: _minSize,
        foregroundColor: accent,
        backgroundColor: AppColors.surfaceContainerLow.withValues(alpha: 0.92),
        side: BorderSide(color: accent.withValues(alpha: 0.55), width: 1.5),
        disabledForegroundColor: AppColors.onSurfaceMuted,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: labelStyle?.copyWith(color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
