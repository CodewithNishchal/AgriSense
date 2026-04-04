import 'package:flutter/material.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/session/user_prefs.dart';
import '../../../core/session/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_primary_button.dart';
import '../../../core/widgets/editorial_scaffold.dart';

/// E3 — Equipment P2P browse with optimistic rent ([design.md]).
class EquipmentMarketplaceScreen extends StatefulWidget {
  const EquipmentMarketplaceScreen({super.key});

  @override
  State<EquipmentMarketplaceScreen> createState() =>
      _EquipmentMarketplaceScreenState();
}

class _EquipmentListing {
  _EquipmentListing({
    required this.id,
    required this.title,
    required this.owner,
    required this.district,
    required this.assetType,
    required this.rateLabel,
  });

  final String id;
  final String title;
  final String owner;
  final String district;
  final String assetType;
  final String rateLabel;
}

class _EquipmentMarketplaceScreenState extends State<EquipmentMarketplaceScreen> {
  static final List<String> _districts = [
    'All districts',
    'Nagpur',
    'Pune',
    'Haryana',
    'Hyderabad',
  ];

  String _district = _districts.first;

  final List<_EquipmentListing> _items = [
    _EquipmentListing(
      id: '1',
      title: 'Tractor — 45 HP',
      owner: 'Singh Agro Rentals',
      district: 'Nagpur',
      assetType: 'Tractor',
      rateLabel: '₹2,400 / day',
    ),
    _EquipmentListing(
      id: '2',
      title: 'Mounted sprayer 600L',
      owner: 'GreenField Co-op',
      district: 'Pune',
      assetType: 'Sprayer',
      rateLabel: '₹900 / day',
    ),
    _EquipmentListing(
      id: '3',
      title: 'Combine harvester',
      owner: 'North Belt Equipment',
      district: 'Haryana',
      assetType: 'Harvester',
      rateLabel: '₹18,500 / acre',
    ),
  ];

  final Map<String, bool> _rentedOptimistic = {};
  final Set<String> _rentInFlight = {};

  Future<void> _onRent(_EquipmentListing item) async {
    if (_rentInFlight.contains(item.id)) return;
    setState(() {
      _rentInFlight.add(item.id);
      _rentedOptimistic[item.id] = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final bool simulateFailure = item.id == '2';

    setState(() {
      _rentInFlight.remove(item.id);
      if (simulateFailure) {
        _rentedOptimistic[item.id] = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not confirm rental. Try again.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _onRent(item),
            ),
          ),
        );
      }
    });
  }

  List<_EquipmentListing> get _visible {
    if (_district == _districts.first) return _items;
    return _items.where((e) => e.district == _district).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gutter = context.layoutGutter;
    return EditorialScaffold(
      title: 'Rent equipment',
      leading: UserPrefs.instance.role == UserRole.farmer
          ? backToMainAppLeading(context)
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= AppBreakpoint.md;
              final title = Text(
                'P2P marketplace',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              );
              final filter = DropdownButtonFormField<String>(
                initialValue: _district,
                dropdownColor: AppColors.surfaceContainerHigh,
                decoration: InputDecoration(
                  labelText: 'District',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _districts
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text(d),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _district = v);
                },
              );
              if (wide) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(flex: 2, child: title),
                      const SizedBox(width: 24),
                      Expanded(flex: 3, child: filter),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: title,
                  ),
                  filter,
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(top: 8, bottom: gutter),
              itemCount: _visible.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _visible[index];
                final rented = _rentedOptimistic[item.id] ?? false;
                final busy = _rentInFlight.contains(item.id);
                return _EquipmentCard(
                  item: item,
                  rented: rented,
                  busy: busy,
                  onRent: () => _onRent(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({
    required this.item,
    required this.rented,
    required this.busy,
    required this.onRent,
  });

  final _EquipmentListing item;
  final bool rented;
  final bool busy;
  final VoidCallback onRent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: rented || busy ? null : onRent,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.precision_manufacturing_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.owner,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.district} · ${item.assetType}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.onSurfaceMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    item.rateLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  if (busy)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (rented)
                    FilledButton(
                      onPressed: null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainerHighest,
                        foregroundColor: AppColors.onSurface,
                      ),
                      child: const Text('Rented!'),
                    )
                  else
                    EditorialPrimaryButton(
                      label: 'Rent now',
                      onPressed: onRent,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
