import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class MarketDetailScreen extends StatelessWidget {
  const MarketDetailScreen({
    super.key,
    required this.commodityName,
  });

  final String commodityName;

  static List<Map<String, dynamic>> _mockHistory(String name) {
    return List.generate(
      7,
      (i) => {
        'date': 'Day ${i + 1}',
        'price': 30.0 + (i * 2) + (i.isEven ? 2.0 : 0),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = _mockHistory(commodityName);
    return EditorialScaffold(
      title: commodityName,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= AppBreakpoint.md;

          final summaryCard = Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      '₹42/kg',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Best selling',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      'Thu–Sat, 6–9 AM',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          );

          final trendTitle = Text(
            'Price trend (last 7 days)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                ),
          );

          final chart = SizedBox(
            height: wide ? 200 : 180,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: history.map((e) {
                    final p = e['price'] as double;
                    const maxP = 50.0;
                    final h = (p / maxP) * 120;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: h,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              e['date'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );

          return SingleChildScrollView(
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: summaryCard,
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            trendTitle,
                            const SizedBox(height: 12),
                            chart,
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      summaryCard,
                      const SizedBox(height: 24),
                      trendTitle,
                      const SizedBox(height: 12),
                      chart,
                    ],
                  ),
          );
        },
      ),
    );
  }
}
