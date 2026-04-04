import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/location/location_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  static const _mockDiseaseSteps = <String>[
    'Isolate affected plants to slow spread.',
    'Remove yellowed leaves; destroy debris off-field.',
    'Apply copper-based fungicide per label (7–10 day interval).',
    'Avoid overhead irrigation; improve row airflow.',
  ];

  Future<void> _runDiseaseFlow(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 88,
    );
    if (file == null || !mounted) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    String? locationLabel;
    try {
      final pos = await LocationHelper.getCurrentPosition();
      locationLabel = pos != null ? LocationHelper.formatPosition(pos) : null;
    } catch (_) {
      locationLabel = null;
    }
    if (!mounted) return;
    setState(() => _loading = false);
    await context.push<void>(
      '/disease-result',
      extra: {
        'diseaseName': 'Tomato Late Blight',
        'confidence': 0.92,
        'treatment':
            'Remove affected leaves. Apply copper-based fungicide every 7–10 days. Avoid overhead irrigation. Ensure good air circulation.',
        'remediationSteps': _mockDiseaseSteps,
        'imagePath': file.path,
        'locationLabel': locationLabel,
      },
    );
  }

  Future<void> _runPestFlow(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 88,
    );
    if (file == null || !mounted) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
    await context.push<void>(
      '/pest-result',
      extra: {
        'pestName': 'Aphids',
        'controlMethod':
            'Spray neem oil solution (5%) or soap water. Introduce ladybugs. Remove heavily infested parts.',
        'affectedCrops': 'Tomato, chilli, cotton, many vegetables',
        'imagePath': file.path,
      },
    );
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
          final disease = _ScanOptionCard(
            icon: Icons.eco_rounded,
            title: 'Disease detection',
            subtitle:
                'Gallery or camera — mock ML result (wire to /api/analyze).',
            color: AppColors.primary,
            onGallery: () => _runDiseaseFlow(ImageSource.gallery),
            onCamera: () => _runDiseaseFlow(ImageSource.camera),
          );
          final pest = _ScanOptionCard(
            icon: Icons.bug_report_rounded,
            title: 'Pest identification',
            subtitle: 'Capture the insect for a demo control plan.',
            color: AppColors.primaryLight,
            onGallery: () => _runPestFlow(ImageSource.gallery),
            onCamera: () => _runPestFlow(ImageSource.camera),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose scan type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Camera uses the device lens; coordinates attach when location permission is granted.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: disease),
                    const SizedBox(width: 16),
                    Expanded(child: pest),
                  ],
                )
              else ...[
                disease,
                const SizedBox(height: 16),
                pest,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ScanOptionCard extends StatelessWidget {
  const _ScanOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onGallery,
    required this.onCamera,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
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
        ),
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
