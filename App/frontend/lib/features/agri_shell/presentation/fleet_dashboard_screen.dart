import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';
import '../data/mock_fleet_data.dart';

/// Lender ops hub — mock map, ledger countdown, alerts (wire to /api/fleet/*).
class FleetDashboardScreen extends StatefulWidget {
  const FleetDashboardScreen({super.key});

  @override
  State<FleetDashboardScreen> createState() => _FleetDashboardScreenState();
}

class _FleetDashboardScreenState extends State<FleetDashboardScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Color _pinColor(FleetPinStatus s) {
    return switch (s) {
      FleetPinStatus.available => const Color(0xFF4CAF50),
      FleetPinStatus.rented => const Color(0xFFFFC107),
      FleetPinStatus.maintenance => const Color(0xFFE53935),
    };
  }

  @override
  Widget build(BuildContext context) {
    final overview = MockFleetData.overview;
    final pins = MockFleetData.pins;
    final ledger = MockFleetData.ledger();
    final alerts = MockFleetData.alerts();
    final now = DateTime.now();

    const center = LatLng(21.15, 79.09);

    final markers = pins
        .map(
          (p) => Marker(
            point: p.position,
            width: 40,
            height: 40,
            child: Tooltip(
              message: '${p.label} · ${p.status.name}',
              child: Icon(
                Icons.location_on_rounded,
                color: _pinColor(p.status),
                size: 40,
              ),
            ),
          ),
        )
        .toList();

    final viewH = MediaQuery.sizeOf(context).height;
    final mapHeight = (viewH * 0.42).clamp(300.0, 540.0);

    return EditorialScaffold(
      title: 'Fleet & rentals',
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'P2P fleet marketplace',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fleet KPIs — connect live data when your backend is ready.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
            ),
            const SizedBox(height: 12),
            _FleetOverviewBar(overview: overview),
            const SizedBox(height: 10),
            _CategoryBars(),
            const SizedBox(height: 10),
            for (final a in alerts) ...[
              _AlertCard(alert: a),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
            Text(
              'Fleet map',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: mapHeight,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.hardEdge,
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: center,
                    initialZoom: 11,
                    minZoom: 3,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.agrises.app',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '© OpenStreetMap contributors',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceMuted,
                        fontSize: 10,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Live rental ledger',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ...List.generate(ledger.length, (i) {
              final row = ledger[i];
              final rem = row.remaining(now);
              final prog = row.progressFraction(now);
              return Padding(
                padding: EdgeInsets.only(bottom: i < ledger.length - 1 ? 10 : 0),
                child: _LedgerRowCard(
                  row: row,
                  remaining: rem,
                  progress: prog,
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

String _formatFleetRemaining(Duration d) {
  if (d == Duration.zero) return 'Ending…';
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) return '${h}h ${m}m left';
  if (m > 0) return '${m}m ${s}s left';
  return '${s}s left';
}

class _LedgerRowCard extends StatelessWidget {
  const _LedgerRowCard({
    required this.row,
    required this.remaining,
    required this.progress,
  });

  final FleetLedgerRow row;
  final Duration remaining;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.asset,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Text(
                _formatFleetRemaining(remaining),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Renter: ${row.renter}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FleetOverviewBar extends StatelessWidget {
  const _FleetOverviewBar({required this.overview});

  final Map<String, String> overview;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _mini(
            context,
            'Fleet units',
            overview['units']!,
            Icons.agriculture_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _mini(
            context,
            'Today (accrued)',
            overview['revenue']!,
            Icons.payments_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _mini(
            context,
            'Utilization',
            overview['utilization']!,
            Icons.stacked_bar_chart_rounded,
          ),
        ),
      ],
    );
  }

  Widget _mini(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBars extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cats = [
      ('Tractors', 0.72),
      ('Sprayers', 0.55),
      ('Harvesters', 0.38),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fleet mix (by hours booked)',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        ...cats.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      c.$1,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${(c.$2 * 100).round()}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceMuted,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: c.$2,
                    minHeight: 6,
                    backgroundColor:
                        AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final TelematicsAlert alert;

  @override
  Widget build(BuildContext context) {
    final border = alert.severity >= 2
        ? AppColors.error.withValues(alpha: 0.45)
        : AppColors.accent.withValues(alpha: 0.45);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: alert.severity >= 2 ? AppColors.error : AppColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
