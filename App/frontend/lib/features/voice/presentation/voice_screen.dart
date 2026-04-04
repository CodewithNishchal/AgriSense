import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/editorial_scaffold.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditorialScaffold(
      title: 'Voice assistant',
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic_rounded, size: 80, color: AppColors.primary),
                    const SizedBox(height: 24),
                    Text(
                      'Tap to speak',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.onSurface,
                          ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.mic_rounded),
                      label: const Text('Start listening'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
