import 'package:flutter/material.dart';

/// Layout tokens aligned with splash / login (Tailwind-style breakpoints).
abstract final class AppBreakpoint {
  AppBreakpoint._();

  static const double sm = 600;
  static const double md = 768;
  static const double lg = 1024;
  static const double xl = 1280;

  /// Two-column auth split (login / signup).
  static const double authSplit = 900;

  /// Max width for readable, centered content on large displays.
  static const double maxContent = 1200;

  static const double maxContentWide = 1400;
}

/// Responsive helpers — use from `build` via [MediaQuery].
extension AppLayoutX on BuildContext {
  double get appWidth => MediaQuery.sizeOf(this).width;

  double get appHeight => MediaQuery.sizeOf(this).height;

  bool get isCompact => appWidth < AppBreakpoint.md;

  bool get isMedium =>
      appWidth >= AppBreakpoint.md && appWidth < AppBreakpoint.lg;

  bool get isWide => appWidth >= AppBreakpoint.lg;

  bool get isExtraWide => appWidth >= AppBreakpoint.xl;

  /// Horizontal gutter for screen edges.
  double get layoutGutter {
    if (appWidth >= AppBreakpoint.lg) return 32;
    if (appWidth >= AppBreakpoint.md) return 24;
    return 16;
  }

  EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: layoutGutter);

  EdgeInsets screenPaddingWithVertical({double top = 16, double bottom = 24}) {
    return EdgeInsets.fromLTRB(layoutGutter, top, layoutGutter, bottom);
  }

  /// Capped width for main column (tablet/desktop centering).
  double get contentMaxWidth {
    final w = appWidth - layoutGutter * 2;
    return w > AppBreakpoint.maxContent ? AppBreakpoint.maxContent : w;
  }

  double get contentMaxWidthWide {
    final w = appWidth - layoutGutter * 2;
    return w > AppBreakpoint.maxContentWide
        ? AppBreakpoint.maxContentWide
        : w;
  }

  /// Quick action / shortcut grid columns.
  int get quickActionColumns {
    if (appWidth >= 1200) return 4;
    if (appWidth >= AppBreakpoint.md) return 3;
    return 2;
  }

  /// Tools / list tiles: 1 column phone, 2 on wide desktop.
  int get toolsColumns {
    if (appWidth >= AppBreakpoint.lg) return 2;
    return 1;
  }

  bool get useAuthSplit => appWidth >= AppBreakpoint.authSplit;
}
