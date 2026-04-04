import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/location/location_helper.dart';
import '../../../core/session/user_prefs.dart';
import '../../../core/session/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_primary_button.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class DiseaseResultScreen extends StatelessWidget {
  const DiseaseResultScreen({
    super.key,
    required this.diseaseName,
    required this.confidence,
    required this.treatment,
    this.imagePath,
    this.remediationSteps,
    this.locationLabel,
    this.fullReport,
  });

  final String diseaseName;
  final double confidence;
  final String treatment;
  final String? imagePath;
  final List<String>? remediationSteps;
  final String? locationLabel;
  final Map<String, dynamic>? fullReport;

  String _confidenceDisplay() {
    final r = fullReport;
    if (r != null) {
      final c = r['confidence'];
      if (c is num && c > 1) return '${c.toStringAsFixed(2)}%';
      final raw = r['confidence_raw'];
      if (raw is num) return '${(raw * 100).toStringAsFixed(2)}%';
    }
    return '${(confidence * 100).clamp(0, 100).toStringAsFixed(0)}%';
  }

  String _titleLine() {
    final r = fullReport;
    final d = r?['disease']?.toString();
    if (d != null && d.isNotEmpty) return d;
    return diseaseName;
  }

  bool _reportLooksHealthy() {
    final r = fullReport;
    if (r == null) return false;
    final key = r['disease_key']?.toString().toLowerCase() ?? '';
    if (key.contains('healthy')) return true;
    if (r['disease_type'] == 'healthy') return true;
    final t = r['disease']?.toString().toLowerCase() ?? '';
    return t.contains('healthy');
  }

  /// 0.0–1.0 for progress bar / tint strength.
  double _confidenceFraction() {
    final r = fullReport;
    if (r != null) {
      final raw = r['confidence_raw'];
      if (raw is num) return raw.toDouble().clamp(0.0, 1.0);
      final c = r['confidence'];
      if (c is num) {
        return c > 1 ? (c / 100.0).clamp(0.0, 1.0) : c.toDouble().clamp(0.0, 1.0);
      }
    }
    return confidence.clamp(0.0, 1.0);
  }

  Future<void> _onSendForAnalyzing(BuildContext context) async {
    final pos = await LocationHelper.getCurrentPosition();
    final payload = _buildAnalyzePayload(
      pos?.latitude,
      pos?.longitude,
    );
    final json = const JsonEncoder.withIndent('  ').convert(payload);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payload for analysis'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.sizeOf(ctx).height * 0.5,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    height: 1.35,
                  ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('JSON copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Copy JSON'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _buildAnalyzePayload(double? lat, double? lon) {
    final r = fullReport;
    if (r != null) {
      final out = Map<String, dynamic>.from(r);
      final loc = <String, dynamic>{};
      final existing = r['location'];
      if (existing is Map) {
        for (final e in existing.entries) {
          loc[e.key.toString()] = e.value;
        }
      }
      loc['lat'] = lat ?? loc['lat'];
      loc['lon'] = lon ?? loc['lon'];
      out['location'] = loc;
      out['timestamp'] = DateTime.now().toUtc().toIso8601String();
      return out;
    }
    return <String, dynamic>{
      'disease': diseaseName,
      'confidence': confidence > 1 ? confidence : confidence * 100,
      'first_aid': treatment,
      'action_plan': remediationSteps ?? <String>[],
      'location': <String, dynamic>{'lat': lat, 'lon': lon},
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Disease result',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide =
              constraints.maxWidth >= AppBreakpoint.md && imagePath != null;

          final image = imagePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: wide
                      ? AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.file(
                          File(imagePath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                )
              : null;

          final steps = (remediationSteps != null &&
                  remediationSteps!.isNotEmpty)
              ? remediationSteps!
              : [treatment];

          final report = fullReport;
          final scanTimeRaw = report?['scan_time_display']?.toString().trim();
          final Widget? scanTimeHeader =
              (scanTimeRaw != null && scanTimeRaw.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan record',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              scanTimeRaw,
                              textAlign: TextAlign.end,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : null;

          final looksHealthy = _reportLooksHealthy();
          final confFrac = _confidenceFraction();
          final accent = looksHealthy ? AppColors.success : AppColors.error;
          final cardFill = looksHealthy
              ? AppColors.success.withValues(alpha: 0.08)
              : AppColors.error.withValues(alpha: 0.10);
          final cardBorder = looksHealthy
              ? AppColors.success.withValues(alpha: 0.42)
              : AppColors.error.withValues(alpha: 0.50);
          final titleAccent =
              looksHealthy ? AppColors.success : AppColors.error;

          final detailCard = Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                cardFill,
                AppColors.surfaceContainer,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        looksHealthy
                            ? Icons.verified_rounded
                            : Icons.warning_amber_rounded,
                        color: accent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diagnosis result',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _titleLine(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: titleAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_confidenceDisplay()} confidence',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'CONFIDENCE',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.onSurfaceMuted,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(confFrac * 100).clamp(0, 100).toStringAsFixed(1)}%',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: confFrac.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor:
                        AppColors.outlineVariant.withValues(alpha: 0.45),
                    color: accent,
                  ),
                ),
                if (report != null) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (report['crop'] != null)
                        _InfoChip(
                          icon: Icons.agriculture_outlined,
                          label: 'Crop: ${report['crop']}',
                        ),
                      if (report['severity'] != null)
                        _InfoChip(
                          icon: Icons.warning_amber_outlined,
                          label: report['severity'].toString(),
                        ),
                      if (report['disease_type'] != null)
                        _InfoChip(
                          icon: Icons.biotech_outlined,
                          label:
                              'Type: ${report['disease_type'].toString().toUpperCase()}',
                        ),
                      if (report['is_positive'] != null)
                        _InfoChip(
                          icon: Icons.verified_outlined,
                          label:
                              'Positive: ${report['is_positive'] == true ? 'YES' : 'NO'}',
                        ),
                    ],
                  ),
                  if (report['first_aid'] != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      'First-aid remedy',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report['first_aid'].toString(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.45,
                            color: AppColors.onSurface,
                          ),
                    ),
                  ],
                ],
                if (locationLabel != null && locationLabel!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Chip(
                    avatar: Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      'Scan location: $locationLabel',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    backgroundColor:
                        AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  report != null ? 'Action plan' : 'Remediation steps',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 8),
                ..._planLines(report, steps).map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Expanded(
                          child: Text(
                            s,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  height: 1.45,
                                  color: AppColors.onSurface,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (report != null && report['weather_advice'] != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Weather-contextual advice',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report['weather_advice'].toString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.45,
                          color: AppColors.onSurface,
                        ),
                  ),
                ],
                if (report != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Yield & economic impact',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yield loss: ${report['yield_loss_pct'] ?? '—'}% · '
                    'Est. loss: ₹${report['economic_loss_rs'] ?? '—'} · '
                    'Per acre: ₹${report['economic_loss_per_acre'] ?? '—'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface,
                        ),
                  ),
                  if (report['marketplace'] is Map) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Marketplace routing',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ..._marketplaceSection(context, report['marketplace'] as Map),
                  ],
                  if (report['top_k_predictions'] is List) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Top predictions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ..._topKRows(context, report['top_k_predictions'] as List),
                  ],
                ],
                const SizedBox(height: 24),
                Text(
                  'Marketplace',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reserve equipment or buy inputs near you (demo navigation).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    EditorialPrimaryButton(
                      label: 'Rent sprayer',
                      onPressed: () {
                        if (UserPrefs.instance.role == UserRole.lender) {
                          context.go('/agri/marketplace');
                        } else {
                          context.go('/farmer/marketplace');
                        }
                      },
                    ),
                    OutlinedButton(
                      onPressed: () => context.push('/market'),
                      child: const Text('Browse market prices'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _onSendForAnalyzing(context),
                    icon: const Icon(Icons.send_rounded, size: 20),
                    label: const Text('Send for analyzing'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimaryFixed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Refreshes GPS in the JSON payload (with scan-time data). Copy from the dialog for your backend.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );

          return SingleChildScrollView(
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: image!,
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (scanTimeHeader != null) scanTimeHeader,
                            detailCard,
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (image != null) ...[
                        image,
                        const SizedBox(height: 24),
                      ],
                      if (scanTimeHeader != null) scanTimeHeader,
                      detailCard,
                    ],
                  ),
          );
        },
      ),
    );
  }
}

List<String> _planLines(Map<String, dynamic>? report, List<String> fallback) {
  if (report == null) return fallback;
  final plan = report['action_plan'];
  if (plan is List && plan.isNotEmpty) {
    return plan.map((e) => e.toString()).toList();
  }
  return fallback;
}

Iterable<Widget> _marketplaceSection(BuildContext context, Map marketplace) {
  final products = marketplace['recommended_products'];
  final note = marketplace['note']?.toString();
  final type = marketplace['product_type']?.toString();
  return [
    if (type != null && type.isNotEmpty)
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          type,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.onSurface,
              ),
        ),
      ),
    if (products is List)
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: products
            .map(
              (e) => Chip(
                label: Text(e.toString()),
                backgroundColor:
                    AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
            )
            .toList(),
      ),
    if (note != null && note.isNotEmpty) ...[
      const SizedBox(height: 8),
      Text(
        note,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
      ),
    ],
  ];
}

Iterable<Widget> _topKRows(BuildContext context, List list) {
  return list.map((raw) {
    if (raw is! Map) return const SizedBox.shrink();
    final rank = raw['rank'];
    final key = raw['disease_key']?.toString() ?? '';
    final conf = raw['confidence'];
    final pct = conf is num
        ? (conf > 1 ? conf : conf * 100).toStringAsFixed(1)
        : '—';
    double barValue = 0;
    if (conf is num) {
      barValue = (conf > 1 ? conf / 100 : conf.toDouble()).clamp(0.0, 1.0);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '#$rank',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: barValue,
                    minHeight: 8,
                    backgroundColor:
                        AppColors.outlineVariant.withValues(alpha: 0.35),
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                child: Text(
                  '$pct%',
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
          if (key.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              key,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  });
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      backgroundColor: AppColors.surfaceContainerHighest.withValues(alpha: 0.45),
    );
  }
}
