import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class SchemesEligibilityScreen extends StatelessWidget {
  const SchemesEligibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Check eligibility',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= AppBreakpoint.md;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter your profile to see eligible govt schemes.',
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
                            labelText: 'Land size (acres)',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: 'Wheat',
                          decoration: const InputDecoration(
                            labelText: 'Primary crop',
                          ),
                          items: ['Wheat', 'Rice', 'Cotton', 'Sugarcane', 'Pulses']
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
                      labelText: 'Land size (acres)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: 'Wheat',
                    decoration: const InputDecoration(
                      labelText: 'Primary crop',
                    ),
                    items: ['Wheat', 'Rice', 'Cotton', 'Sugarcane', 'Pulses']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (_) {},
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'State / Region',
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => context.push('/schemes/list'),
                  child: const Text('Check eligibility'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
