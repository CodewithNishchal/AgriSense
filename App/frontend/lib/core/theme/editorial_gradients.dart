import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Signature CTAs: 135° lush gradient ([design.md](../../../../design.md)).
abstract final class EditorialGradients {
  static const LinearGradient primaryCta = LinearGradient(
    begin: Alignment(-0.85, -0.85),
    end: Alignment(0.85, 0.85),
    colors: [
      AppColors.primary,
      AppColors.primaryContainer,
    ],
  );
}
