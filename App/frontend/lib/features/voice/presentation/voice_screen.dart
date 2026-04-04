import 'package:flutter/material.dart';

import '../../../core/widgets/app_info_page.dart';

/// Voice Q&A for Gemini is on the disease result screen after a scan.
class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppInfoPage(
      title: 'Voice assistant',
      icon: Icons.mic_rounded,
      message:
          'Ask questions by voice on the disease result screen: after you scan a leaf, '
          'open “Ask about this scan”, then record or transcribe your question. '
          'That flow uses your diagnosis report and the AgriSense server (speech recognition and AI advice).',
      primaryRoute: '/scan',
      primaryLabel: 'Open leaf scan',
    );
  }
}
