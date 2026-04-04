import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class MarketListScreen extends StatelessWidget {
  const MarketListScreen({super.key});

  static final List<Map<String, String>> _mockPrices = [
    {'name': 'Tomato', 'price': '₹42/kg', 'mandi': 'Delhi', 'trend': 'up'},
    {'name': 'Onion', 'price': '₹28/kg', 'mandi': 'Nasik', 'trend': 'down'},
    {'name': 'Potato', 'price': '₹22/kg', 'mandi': 'Agra', 'trend': 'stable'},
    {
      'name': 'Wheat',
      'price': '₹2,100/quintal',
      'mandi': 'Punjab',
      'trend': 'up'
    },
    {
      'name': 'Rice',
      'price': '₹3,400/quintal',
      'mandi': 'Chhattisgarh',
      'trend': 'stable'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Market prices',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cols = context.toolsColumns;
          return GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: cols > 1 ? 2.4 : 3.2,
            ),
            itemCount: _mockPrices.length,
            itemBuilder: (context, i) {
              final item = _mockPrices[i];
              return Material(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => context.push('/market/${item['name']}'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['name']!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.onSurface,
                                    ),
                              ),
                              Text(
                                item['mandi']!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          item['price']!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          item['trend'] == 'up'
                              ? Icons.trending_up_rounded
                              : item['trend'] == 'down'
                                  ? Icons.trending_down_rounded
                                  : Icons.trending_flat_rounded,
                          size: 20,
                          color: item['trend'] == 'up'
                              ? AppColors.success
                              : item['trend'] == 'down'
                                  ? AppColors.error
                                  : AppColors.onSurfaceMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
