import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/session/user_prefs.dart';
import '../../../core/session/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';
import '../../../core/widgets/location_prompt_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cols = context.quickActionColumns;
    final pad = context.layoutGutter;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: EditorialBody(
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 24),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: LocationPromptBanner(),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'agriNXT',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your farming companion',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    avatar: Icon(
                      UserPrefs.instance.role == UserRole.lender
                          ? Icons.precision_manufacturing_outlined
                          : Icons.agriculture_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      'Role: ${UserPrefs.instance.role.label}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    backgroundColor:
                        AppColors.surfaceContainerHighest.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: _WeatherCard(
                location: 'Your location',
                temp: '28°C',
                condition: 'Partly cloudy',
                advisory: 'Good day for irrigation. No rain expected.',
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
            SliverToBoxAdapter(
              child: Text(
                'Quick actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: cols >= 4 ? 1.15 : 1.25,
              ),
              delegate: SliverChildListDelegate([
                    _ShortcutCard(
                      icon: Icons.hub_rounded,
                      title: 'AgriNXT',
                      subtitle: UserPrefs.instance.role == UserRole.lender
                          ? 'Map · fleet · rent'
                          : 'Map · scan · rent',
                      color: AppColors.primary,
                      onTap: () {
                        if (UserPrefs.instance.role == UserRole.lender) {
                          context.go('/agri/map');
                        } else {
                          context.go('/farmer/map');
                        }
                      },
                    ),
                    _ShortcutCard(
                      icon: Icons.login_rounded,
                      title: 'Login',
                      subtitle: 'Sign in',
                      color: AppColors.info,
                      onTap: () => context.push('/login'),
                    ),
                    _ShortcutCard(
                      icon: Icons.eco_rounded,
                      title: 'Disease',
                      subtitle: 'Scan leaf',
                      color: AppColors.primary,
                      onTap: () => context.go('/scan'),
                    ),
                    _ShortcutCard(
                      icon: Icons.bug_report_rounded,
                      title: 'Pest ID',
                      subtitle: 'Identify insect',
                      color: AppColors.primaryLight,
                      onTap: () => context.go('/scan'),
                    ),
                    _ShortcutCard(
                      icon: Icons.grass_rounded,
                      title: 'Soil',
                      subtitle: 'NPK and fertilizer',
                      color: const Color(0xFF5C7C2E),
                      onTap: () => context.push('/soil'),
                    ),
                    _ShortcutCard(
                      icon: Icons.agriculture_rounded,
                      title: 'Crop plan',
                      subtitle: 'Rotation and suggest',
                      color: AppColors.accent,
                      onTap: () => context.push('/crop'),
                    ),
                    _ShortcutCard(
                      icon: Icons.show_chart_rounded,
                      title: 'Market',
                      subtitle: 'Mandi prices',
                      color: const Color(0xFF1E5F74),
                      onTap: () => context.push('/market'),
                    ),
                    _ShortcutCard(
                      icon: Icons.psychology_rounded,
                      title: 'Yield',
                      subtitle: 'Predict harvest',
                      color: const Color(0xFF8B6914),
                      onTap: () => context.push('/yield'),
                    ),
                  ]),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    required this.location,
    required this.temp,
    required this.condition,
    required this.advisory,
  });

  final String location;
  final String temp;
  final String condition;
  final String advisory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onBackground.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: AppColors.accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.onSurfaceMuted,
                          ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        temp,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    Text(
                      condition,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    advisory,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface,
                          height: 1.4,
                        ),
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

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.onBackground.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.onSurface,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
