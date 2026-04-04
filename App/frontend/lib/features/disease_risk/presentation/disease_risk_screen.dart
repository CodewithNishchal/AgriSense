import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class DiseaseRiskScreen extends StatelessWidget {
  const DiseaseRiskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Disease risk',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= AppBreakpoint.md;

          Widget humidity() => TextFormField(
                initialValue: '75',
                decoration: const InputDecoration(
                  labelText: 'Humidity (%)',
                ),
                keyboardType: TextInputType.number,
              );

          Widget temp() => TextFormField(
                initialValue: '28',
                decoration: const InputDecoration(
                  labelText: 'Temperature (°C)',
                ),
                keyboardType: TextInputType.number,
              );

          Widget rain() => TextFormField(
                initialValue: '12',
                decoration: const InputDecoration(
                  labelText: 'Rainfall (mm)',
                ),
                keyboardType: TextInputType.number,
              );

          Widget crop() => DropdownButtonFormField<String>(
                initialValue: 'Rice',
                decoration: const InputDecoration(
                  labelText: 'Crop',
                ),
                items: ['Rice', 'Wheat', 'Cotton', 'Tomato', 'Chilli']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (_) {},
              );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Based on weather and crop, get pre-emptive disease risk.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: humidity()),
                      const SizedBox(width: 16),
                      Expanded(child: temp()),
                    ],
                  )
                else ...[
                  humidity(),
                  const SizedBox(height: 16),
                  temp(),
                ],
                const SizedBox(height: 16),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: rain()),
                      const SizedBox(width: 16),
                      Expanded(child: crop()),
                    ],
                  )
                else ...[
                  rain(),
                  const SizedBox(height: 16),
                  crop(),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Check risk'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
