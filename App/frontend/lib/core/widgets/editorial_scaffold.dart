import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../layout/app_breakpoints.dart';
import '../theme/app_colors.dart';

/// Standard page shell: dark background, optional [AppBar], body constrained and padded.
class EditorialScaffold extends StatelessWidget {
  const EditorialScaffold({
    super.key,
    required this.title,
    required this.body,
    this.leading,
    this.actions,
    this.centerTitle,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  /// When non-null, replaces default [AppBar] leading (e.g. back to main app from Agri hub).
  final Widget? leading;
  final List<Widget>? actions;
  final bool? centerTitle;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(title),
        centerTitle: centerTitle,
        leading: leading,
        automaticallyImplyLeading: leading == null,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.contentMaxWidthWide,
            ),
            child: Padding(
              padding: context.screenPaddingWithVertical(top: 8, bottom: 16),
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}

/// App bar leading: back to the main [AppShell] home (farmer standalone `/farmer/*` routes).
Widget backToMainAppLeading(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.arrow_back_rounded),
    tooltip: 'Home',
    onPressed: () => context.go('/'),
  );
}

/// Centers [child] with max width + horizontal padding (for custom [CustomScrollView] roots).
class EditorialBody extends StatelessWidget {
  const EditorialBody({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? context.contentMaxWidthWide,
          ),
          child: Padding(
            padding: padding ??
                context.screenPaddingWithVertical(top: 8, bottom: 16),
            child: child,
          ),
        ),
      ),
    );
  }
}
