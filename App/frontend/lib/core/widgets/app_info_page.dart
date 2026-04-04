import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import 'editorial_scaffold.dart';

/// Simple placeholder for sections not yet fully implemented.
class AppInfoPage extends StatelessWidget {
  const AppInfoPage({
    super.key,
    required this.title,
    required this.icon,
    this.message,
    this.primaryRoute,
    this.primaryLabel,
  });

  final String title;
  final IconData icon;
  final String? message;
  final String? primaryRoute;
  final String? primaryLabel;

  @override
  Widget build(BuildContext context) {
    final bodyText = message?.trim().isNotEmpty == true
        ? message!
        : 'This section is not available yet. Check back in a future update.';

    return EditorialScaffold(
      title: title,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            bodyText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: 28),
          if (primaryRoute != null && primaryRoute!.isNotEmpty)
            FilledButton(
              onPressed: () {
                final r = primaryRoute!;
                if (r == '/') {
                  context.go('/');
                } else {
                  context.go(r);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimaryFixed,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(primaryLabel ?? 'Continue'),
            ),
        ],
      ),
    );
  }
}
