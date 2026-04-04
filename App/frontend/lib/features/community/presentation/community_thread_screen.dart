import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class CommunityThreadScreen extends StatelessWidget {
  const CommunityThreadScreen({
    super.key,
    required this.threadId,
  });

  final String threadId;

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Question',
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yellow spots on tomato leaves. What to do?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ramesh · 2 hours ago · #$threadId',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Replies',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          const _ReplyTile(
            text:
                'Could be early blight. Try copper-based spray and remove affected leaves.',
            author: 'Expert',
            isExpert: true,
          ),
          const _ReplyTile(
            text: 'Same issue last year. Neem oil helped.',
            author: 'Vijay',
            isExpert: false,
          ),
        ],
      ),
    );
  }
}

class _ReplyTile extends StatelessWidget {
  const _ReplyTile({
    required this.text,
    required this.author,
    required this.isExpert,
  });

  final String text;
  final String author;
  final bool isExpert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isExpert
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  author,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isExpert ? AppColors.primary : AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (isExpert) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Expert',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
