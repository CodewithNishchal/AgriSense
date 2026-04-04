import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static const List<_ToolDef> _tools = [
    _ToolDef(
      icon: Icons.terrain_rounded,
      title: 'Soil recommendation',
      subtitle: 'NPK, pH → fertilizer',
      route: '/soil',
    ),
    _ToolDef(
      icon: Icons.eco_rounded,
      title: 'Crop recommendation',
      subtitle: 'Rotation & next crop',
      route: '/crop',
    ),
    _ToolDef(
      icon: Icons.wb_sunny_rounded,
      title: 'Weather advisory',
      subtitle: 'Alerts & farming tips',
      route: '/weather',
    ),
    _ToolDef(
      icon: Icons.warning_amber_rounded,
      title: 'Disease risk',
      subtitle: 'Pre-emptive risk %',
      route: '/disease-risk',
    ),
    _ToolDef(
      icon: Icons.show_chart_rounded,
      title: 'Market prices',
      subtitle: 'Mandi & trends',
      route: '/market',
    ),
    _ToolDef(
      icon: Icons.analytics_rounded,
      title: 'Yield prediction',
      subtitle: 'Expected harvest',
      route: '/yield',
    ),
    _ToolDef(
      icon: Icons.mic_rounded,
      title: 'Voice assistant',
      subtitle: 'Ask in your language',
      route: '/voice',
    ),
    _ToolDef(
      icon: Icons.sensors_rounded,
      title: 'IoT dashboard',
      subtitle: 'Soil sensors (mock)',
      route: '/iot',
    ),
    _ToolDef(
      icon: Icons.satellite_alt_rounded,
      title: 'Satellite view',
      subtitle: 'NDVI / stress (mock)',
      route: '/satellite',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Tools',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final twoCol = context.toolsColumns >= 2;
          if (!twoCol) {
            return ListView(
              children: [
                for (final t in _tools)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ToolTile(
                      icon: t.icon,
                      title: t.title,
                      subtitle: t.subtitle,
                      onTap: () => context.push(t.route),
                    ),
                  ),
              ],
            );
          }
          return SingleChildScrollView(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
              ),
              itemCount: _tools.length,
              itemBuilder: (context, i) {
                final t = _tools[i];
                return _ToolTile(
                  icon: t.icon,
                  title: t.title,
                  subtitle: t.subtitle,
                  onTap: () => context.push(t.route),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ToolDef {
  const _ToolDef({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceMuted),
            ],
          ),
        ),
      ),
    );
  }
}
