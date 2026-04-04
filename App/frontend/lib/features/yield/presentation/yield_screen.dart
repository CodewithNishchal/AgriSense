import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class YieldScreen extends StatelessWidget {
  const YieldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Yield prediction',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= AppBreakpoint.md;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Get expected yield based on crop and region.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: 'Wheat',
                          decoration: const InputDecoration(labelText: 'Crop'),
                          items: ['Wheat', 'Rice', 'Cotton', 'Sugarcane', 'Maize']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (_) {},
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Region'),
                        ),
                      ),
                    ],
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    initialValue: 'Wheat',
                    decoration: const InputDecoration(labelText: 'Crop'),
                    items: ['Wheat', 'Rice', 'Cotton', 'Sugarcane', 'Maize']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Region'),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Area (acres)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Predict yield'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
