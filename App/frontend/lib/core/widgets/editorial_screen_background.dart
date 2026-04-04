import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/editorial_asset_urls.dart';

/// Full-bleed editorial imagery (login + signup heroes) with a dark read legibility scrim.
/// Place behind content via [MaterialApp.router] `builder` or a [Stack].
class EditorialScreenBackground extends StatelessWidget {
  const EditorialScreenBackground({super.key});

  static Widget _fallback() {
    return ColoredBox(
      color: AppColors.surfaceContainerLow,
      child: Center(
        child: Icon(
          Icons.landscape_rounded,
          size: 96,
          color: AppColors.primary.withValues(alpha: 0.35),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.42,
            child: Image.network(
              EditorialAssetUrls.signupEditorial,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(),
            ),
          ),
        ),
        Positioned.fill(
          child: Image.network(
            EditorialAssetUrls.loginHero,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withValues(alpha: 0.35),
                  AppColors.background.withValues(alpha: 0.88),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
