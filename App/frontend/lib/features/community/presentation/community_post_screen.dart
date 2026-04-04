import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/app_breakpoints.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class CommunityPostScreen extends StatelessWidget {
  const CommunityPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Ask question',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= AppBreakpoint.md;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Your question',
                    hintText: 'Describe your issue or ask for advice',
                  ),
                  maxLines: wide ? 6 : 4,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.image_rounded),
                  label: const Text('Add photo'),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: const Text('Post'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
