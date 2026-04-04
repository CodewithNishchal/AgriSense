import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class SchemesListScreen extends StatelessWidget {
  const SchemesListScreen({super.key});

  static final List<Map<String, String>> _mock = [
    {
      'title': 'PM-KISAN',
      'desc':
          'Income support for farmers. ₹6,000/year in 3 instalments.',
      'link': 'pmkisan.gov.in'
    },
    {
      'title': 'Soil Health Card',
      'desc': 'Free soil testing and recommendation.',
      'link': 'soilhealth.dac.gov.in'
    },
    {
      'title': 'Fasal Bima Yojana',
      'desc': 'Crop insurance at subsidised premium.',
      'link': 'pmfby.gov.in'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Eligible schemes',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= AppBreakpoint.md;
          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: _mock.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final s = _mock[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              s['title']!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s['desc']!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s['link']!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.accent,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s['title']!,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s['desc']!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.onSurface,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s['link']!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.accent,
                                ),
                          ),
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
