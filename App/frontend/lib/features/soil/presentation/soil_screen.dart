import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class SoilScreen extends StatelessWidget {
  const SoilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Soil recommendation',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= AppBreakpoint.md;

          Widget cropField() => DropdownButtonFormField<String>(
                initialValue: 'Wheat',
                decoration: const InputDecoration(
                  labelText: 'Crop',
                ),
                items: ['Wheat', 'Rice', 'Cotton', 'Sugarcane', 'Maize']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (_) {},
              );

          Widget nField() => TextFormField(
                initialValue: '45',
                decoration: const InputDecoration(
                  labelText: 'Nitrogen (N) kg/ha',
                ),
                keyboardType: TextInputType.number,
              );

          Widget pField() => TextFormField(
                initialValue: '22',
                decoration: const InputDecoration(
                  labelText: 'Phosphorus (P) kg/ha',
                ),
                keyboardType: TextInputType.number,
              );

          Widget kField() => TextFormField(
                initialValue: '18',
                decoration: const InputDecoration(
                  labelText: 'Potassium (K) kg/ha',
                ),
                keyboardType: TextInputType.number,
              );

          Widget phField() => TextFormField(
                initialValue: '6.2',
                decoration: const InputDecoration(
                  labelText: 'pH',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              );

          final formColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cropField(),
              const SizedBox(height: 16),
              nField(),
              const SizedBox(height: 16),
              pField(),
              const SizedBox(height: 16),
              kField(),
              const SizedBox(height: 16),
              phField(),
            ],
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter soil values for fertilizer recommendation.',
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            cropField(),
                            const SizedBox(height: 16),
                            nField(),
                            const SizedBox(height: 16),
                            pField(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            kField(),
                            const SizedBox(height: 16),
                            phField(),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  formColumn,
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
