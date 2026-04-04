import 'package:flutter/material.dart';

/// Editorial Agronomy — "The Digital Greenhouse" ([design.md](../../../../design.md)).
/// Prefer tone + spacing over 1px borders; use [outlineVariant] with low opacity for ghost strokes only.
abstract final class AppColors {
  // --- Base ---
  static const Color background = Color(0xFF121410);
  static const Color onBackground = Color(0xFFE3E3DC);

  // --- Brand (chartreuse) ---
  static const Color primary = Color(0xFF88DC63);
  static const Color primaryContainer = Color(0xFF6EBF4A);
  /// Highlight on dark backgrounds (e.g. “Smart Farming” on login hero)
  static const Color primaryFixedDim = Color(0xFF87DB62);
  /// Soft accent for ambient blobs / tertiary UI
  static const Color tertiary = Color(0xFF96D5B4);
  /// Text/icons on solid primary / gradient CTA
  static const Color onPrimaryFixed = Color(0xFF0F1A0C);
  /// HTML reference: on-primary for gradient buttons
  static const Color onPrimary = Color(0xFF0F3900);
  static const Color onPrimaryContainer = Color(0xFF0F1A0C);

  // --- Content ---
  static const Color onSurface = Color(0xFFE3E3DC);
  static const Color onSurfaceVariant = Color(0xFFB8BDBA);
  static const Color onSurfaceMuted = Color(0xFF8A938E);

  // --- Surface stack (dark nesting) ---
  static const Color surfaceContainerLowest = Color(0xFF141813);
  static const Color surfaceContainerLow = Color(0xFF1A1F15);
  static const Color surfaceContainer = Color(0xFF222A1F);
  static const Color surfaceContainerHigh = Color(0xFF2A3326);
  static const Color surfaceContainerHighest = Color(0xFF333D2E);

  /// Glass panels (pair with ~60% opacity + backdrop blur)
  static const Color surfaceVariantBase = Color(0xFF1E221C);

  // --- Ghost / outline ---
  static const Color outlineVariant = Color(0xFF40493C);

  // --- Semantic ---
  static const Color success = Color(0xFF88DC63);
  static const Color warning = Color(0xFFC17F0A);
  static const Color error = Color(0xFFB91C1C);
  static const Color errorContainer = Color(0xFF3D1515);
  static const Color info = Color(0xFF6EBF4A);

  // --- Legacy aliases (pre–Editorial screens) ---
  static const Color surface = background;
  static const Color surfaceVariant = surfaceContainerLow;
  static const Color primaryLight = Color(0xFF9EE67A);
  static const Color primaryDark = Color(0xFF4A8C3A);
  static const Color accent = Color(0xFFC9A227);
  static const Color accentLight = Color(0xFFD4B84A);
  static const Color onAccent = Color(0xFF1A1F15);
  static const Color outline = outlineVariant;
}
