import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class CropScreen extends StatelessWidget {
  const CropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Crop recommendation',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= AppBreakpoint.md;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter location and last crop for rotation suggestion.',
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
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Region / Location',
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: 'Wheat',
                          decoration: const InputDecoration(
                            labelText: 'Last crop',
                          ),
                          items: [
                            'Wheat',
                            'Rice',
                            'Cotton',
                            'Sugarcane',
                            'Maize',
                            'Pulses'
                          ]
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (_) {},
                        ),
                      ),
                    ],
                  )
                else ...[
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Region / Location',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: 'Wheat',
                    decoration: const InputDecoration(
                      labelText: 'Last crop',
                    ),
                    items: [
                      'Wheat',
                      'Rice',
                      'Cotton',
                      'Sugarcane',
                      'Maize',
                      'Pulses'
                    ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (_) {},
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Soil summary (optional)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Get recommendation'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
