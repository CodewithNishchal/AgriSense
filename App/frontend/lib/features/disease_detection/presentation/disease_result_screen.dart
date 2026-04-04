import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
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
  });

  final String diseaseName;
  final double confidence;
  final String treatment;
  final String? imagePath;
  final List<String>? remediationSteps;
  final String? locationLabel;

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

          final detailCard = Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diseaseName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: AppColors.onSurface,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(confidence * 100).toStringAsFixed(0)}% confidence',
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
                  ],
                ),
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
                  'Remediation steps',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 8),
                ...steps.map(
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
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.45,
                                  color: AppColors.onSurface,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                        child: detailCard,
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
                      detailCard,
                    ],
                  ),
          );
        },
      ),
    );
  }
}
