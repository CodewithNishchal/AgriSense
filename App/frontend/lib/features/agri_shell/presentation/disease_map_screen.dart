import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../core/session/user_prefs.dart';
import '../../../core/session/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';
import '../data/mock_disease_map_data.dart';

/// Macro command center — OSM + synthetic heat circles + mock charts (no API).
class DiseaseMapScreen extends StatefulWidget {
  const DiseaseMapScreen({super.key});

  @override
  State<DiseaseMapScreen> createState() => _DiseaseMapScreenState();
}

class _DiseaseMapScreenState extends State<DiseaseMapScreen> {
  String _district = MockDiseaseMapData.districts.first;

  @override
  Widget build(BuildContext context) {
    final center = MockDiseaseMapData.centerFor(_district);
    final zoom = _district == 'All India' ? 5.0 : 9.0;
    final circles = MockDiseaseMapData.heatCircles(_district);
    final kpis = MockDiseaseMapData.kpis(_district);
    final series = MockDiseaseMapData.chartSeries(_district);

    final circleMarkers = circles.map((d) {
      final color = switch (d.colorTier) {
        0 => const Color(0x664CAF50),
        1 => const Color(0x88FFC107),
        _ => const Color(0x99E53935),
      };
      return CircleMarker(
        point: d.center,
        radius: d.radius,
        color: color,
        borderStrokeWidth: 0,
      );
    }).toList();

    final viewH = MediaQuery.sizeOf(context).height;
    // Scrollable page: give map + chart generous fixed heights from viewport.
    final mapHeight = (viewH * 0.44).clamp(300.0, 560.0);
    final chartHeight = (viewH * 0.36).clamp(260.0, 440.0);

    return EditorialScaffold(
      title: 'Disease intelligence map',
      leading: UserPrefs.instance.role == UserRole.farmer
          ? backToMainAppLeading(context)
          : null,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Macro command center',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Demo heat + KPIs · wire to /api/scans/heatmap & /api/charts.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              isDense: true,
              initialValue: _district,
              decoration: const InputDecoration(
                labelText: 'District / region',
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: MockDiseaseMapData.districts
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _district = v);
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 68,
              child: _KpiStrip(kpis: kpis),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: mapHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: zoom,
                    minZoom: 3,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.hacksagon.agrinxt',
                    ),
                    CircleLayer(circles: circleMarkers),
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
              'Diagnostics vs atmospheric model (mock)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: chartHeight,
              child: _CorrelationChart(
                historical: series.historical,
                forecast: series.forecast,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Single horizontal row — avoids tall Wrap on phones so the map keeps height.
class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.kpis});

  final Map<String, String> kpis;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ('Scans', kpis['scans']!, Icons.biotech_rounded),
      ('Active', kpis['active']!, Icons.coronavirus_outlined),
      ('Risk', kpis['risk']!, Icons.currency_rupee_rounded),
      ('Officers', kpis['officers']!, Icons.support_agent_rounded),
    ];
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: tiles.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        final e = tiles[i];
        return SizedBox(
          width: 132,
          child: _KpiTile(
            label: e.$1,
            value: e.$2,
            icon: e.$3,
            compact: true,
          ),
        );
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: compact ? 18 : 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: compact ? 10 : null,
                      ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 13 : null,
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

class _CorrelationChart extends StatelessWidget {
  const _CorrelationChart({
    required this.historical,
    required this.forecast,
  });

  final List<double> historical;
  final List<double> forecast;

  @override
  Widget build(BuildContext context) {
    final histSpots = <FlSpot>[
      for (var i = 0; i < historical.length; i++)
        FlSpot(i.toDouble(), historical[i]),
    ];
    final foreSpots = <FlSpot>[
      for (var i = 0; i < forecast.length; i++) FlSpot(i.toDouble(), forecast[i]),
    ];

    return Card(
      color: AppColors.surfaceContainer.withValues(alpha: 0.9),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
        child: LineChart(
          LineChartData(
            minY: 0,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 40,
              getDrawingHorizontalLine: (_) => FlLine(
                color: AppColors.outlineVariant.withValues(alpha: 0.15),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 34,
                  interval: 40,
                  getTitlesWidget: (v, m) => Text(
                    v.toInt().toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceMuted,
                          fontSize: 9,
                        ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: 2,
                  getTitlesWidget: (v, m) => Text(
                    'w${v.toInt()}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceMuted,
                          fontSize: 10,
                        ),
                  ),
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: histSpots,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
              LineChartBarData(
                spots: foreSpots,
                isCurved: true,
                color: AppColors.accent,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
