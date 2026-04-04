import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  static final List<Map<String, String>> _mock = [
    {
      'q': 'Yellow spots on tomato leaves. What to do?',
      'author': 'Ramesh',
      'replies': '3'},
    {'q': 'Best time to sow wheat in MP?', 'author': 'Suresh', 'replies': '5'},
  ];

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Community',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded),
          onPressed: () => context.push('/community/post'),
        ),
      ],
      body: ListView.builder(
        itemCount: _mock.length,
        itemBuilder: (context, i) {
          final m = _mock[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: () => context.push('/community/thread/$i'),
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m['q']!,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${m['author']} · ${m['replies']} replies',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
