import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class PestResultScreen extends StatelessWidget {
  const PestResultScreen({
    super.key,
    required this.pestName,
    required this.controlMethod,
    required this.affectedCrops,
    this.imagePath,
  });

  final String pestName;
  final String controlMethod;
  final String affectedCrops;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Pest result',
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
                        color: AppColors.primaryLight.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bug_report_rounded,
                        color: AppColors.primaryLight,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        pestName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: AppColors.onSurface,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Affected crops',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  affectedCrops,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Control (bio-pesticide first)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  controlMethod,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                        color: AppColors.onSurface,
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
