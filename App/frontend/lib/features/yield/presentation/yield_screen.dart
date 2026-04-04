import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class YieldScreen extends StatefulWidget {
  const YieldScreen({super.key});

  @override
  State<YieldScreen> createState() => _YieldScreenState();
}

class _YieldScreenState extends State<YieldScreen> {
  String _crop = 'Wheat';
  final _region = TextEditingController(text: 'Punjab');
  final _acres = TextEditingController(text: '2.5');

  @override
  void dispose() {
    _region.dispose();
    _acres.dispose();
    super.dispose();
  }

  void _showYieldEstimate() {
    final acres = double.tryParse(_acres.text.trim()) ?? 1;
    final estQ = (acres * 18.5).toStringAsFixed(1);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yield estimate'),
        content: Text(
          'For $_crop in ${_region.text.trim().isEmpty ? "your region" : _region.text.trim()} '
          'at ${acres.toStringAsFixed(1)} acres:\n\n'
          '• Indicative yield: ~$estQ quintals (illustrative)\n'
          '• Confidence band: ±12%\n\n'
          'Full yield models will use soil, weather, and season data in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

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
                  'Expected harvest from crop, region, and area. Results are illustrative until live models are connected.',
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
                          value: _crop,
                          decoration: const InputDecoration(labelText: 'Crop'),
                          items: ['Wheat', 'Rice', 'Cotton', 'Sugarcane', 'Maize']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _crop = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextFormField(
                          controller: _region,
                          decoration: const InputDecoration(labelText: 'Region'),
                        ),
                      ),
                    ],
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    value: _crop,
                    decoration: const InputDecoration(labelText: 'Crop'),
                    items: ['Wheat', 'Rice', 'Cotton', 'Sugarcane', 'Maize']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _crop = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _region,
                    decoration: const InputDecoration(labelText: 'Region'),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _acres,
                  decoration: const InputDecoration(labelText: 'Area (acres)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _showYieldEstimate,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimaryFixed,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
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
