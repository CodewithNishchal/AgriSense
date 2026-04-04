import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'More',
      body: ListView(
        children: [
          _MoreTile(
            icon: Icons.account_balance_rounded,
            title: 'Govt schemes',
            subtitle: 'Check eligibility',
            onTap: () => context.push('/schemes'),
          ),
          _MoreTile(
            icon: Icons.settings_rounded,
            title: 'Settings',
            subtitle: 'App preferences',
            onTap: () {},
          ),
          _MoreTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & support',
            subtitle: 'FAQs, contact',
            onTap: () {},
          ),
          _MoreTile(
            icon: Icons.info_outline_rounded,
            title: 'About',
            subtitle: 'Version, credits',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceMuted,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
