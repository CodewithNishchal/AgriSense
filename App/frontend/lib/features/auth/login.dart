import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/session/user_prefs.dart';
import '../../core/session/user_role.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/editorial_asset_urls.dart';
import '../../core/theme/editorial_gradients.dart';
import '../../core/widgets/editorial_screen_background.dart';

/// Login — “Digital Greenhouse” glass card layout (matches HTML reference).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Demo-only — replace with API auth.
  static const String _demoEmail = 'test@gmail.com';
  static const String _demoPassword = '123456';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: _demoEmail);
  final _passwordController = TextEditingController(text: _demoPassword);
  bool _obscurePassword = true;
  UserRole _role = UserRole.farmer;

  static const String _googleIconUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuC1Yw75pHOzKZglOwpesfn8RTPii8CbbIe9G9GkWpM8g-EVdm3-onwKTSY7jkR9LrtGs0aDywLnZSdRqprVVFJB6zx-ZcKrMaaMC0F1Nu5nd84alSKpBXi1LyPMmEigjhSERLsdZZSDVB2QobINTKdvUco5b1GD3WAW86I-B1Ts-VCtVwVL-2ncmR1o2l6xlWV6Y70LRaHzvU4aOgTMJcypBqlXgi3DmIwBgfwHywv0N25w3kaBOxTfbfrVPenXQ6ujHSrxLhsLoUi6';

  static const String _appleIconUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAdxQFf9ejBn3TaO6Z_n5YG__5Zy7fYP2dtUFaQFuRk3IlmDzNSdlUU8p6pz6xC1M_yVwrarurS91XAVNtie2FVJngHSjiN2U14qMjjoIl3hZmtXBB3m3TkTsx0XQI6V0ttXzLedVyiA3HZgo_j0WH0W2DWrLXCpWstnAPYPy72L3L-R57oW7JI0emiapPJ8z63QfipGqZRf4M4Yl1fj-3tk1zyqdBTuYSlvlE8jkT2t58R9B3zUQ5Vi2KE9KLVP6yrxRCMtwgAC1p4';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _enterApp() async {
    FocusScope.of(context).unfocus();
    await UserPrefs.instance.setRole(_role);
    if (!context.mounted) return;
    context.go('/');
  }

  void _applyDemoCredentialsAndSubmit() {
    _emailController.text = _demoEmail;
    _passwordController.text = _demoPassword;
    _submit();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email == _demoEmail && password == _demoPassword) {
      await _enterApp();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password. Use the demo account.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= AppBreakpoint.authSplit;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(child: EditorialScreenBackground()),
              _AmbientGlow(
                top: -constraints.maxHeight * 0.1,
                left: -constraints.maxWidth * 0.1,
                size: constraints.maxWidth * 0.5,
                color: AppColors.primary,
              ),
              _AmbientGlow(
                bottom: -constraints.maxHeight * 0.1,
                right: -constraints.maxWidth * 0.1,
                size: constraints.maxWidth * 0.4,
                color: AppColors.tertiary,
              ),
              if (!wide) _MobileBrandTop(),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      wide ? 24 : 72,
                      24,
                      24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0x991E201C),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.outlineVariant
                                    .withValues(alpha: 0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 48,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: wide
                                ? IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              minHeight: 520,
                                            ),
                                            child: _LoginHeroPanel(
                                              imageUrl:
                                                  EditorialAssetUrls.loginHero,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: _LoginFormPanel(
                                            formKey: _formKey,
                                            emailController: _emailController,
                                            passwordController:
                                                _passwordController,
                                            obscurePassword: _obscurePassword,
                                            onTogglePassword: () =>
                                                setState(() =>
                                                    _obscurePassword =
                                                        !_obscurePassword),
                                            selectedRole: _role,
                                            onRoleChanged: (r) =>
                                                setState(() => _role = r),
                                            onSubmit: () {
                                              _submit();
                                            },
                                            onSocialSignIn:
                                                _applyDemoCredentialsAndSubmit,
                                            googleIconUrl: _googleIconUrl,
                                            appleIconUrl: _appleIconUrl,
                                            wide: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : _LoginFormPanel(
                                    formKey: _formKey,
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    obscurePassword: _obscurePassword,
                                    onTogglePassword: () => setState(
                                      () => _obscurePassword =
                                          !_obscurePassword,
                                    ),
                                    selectedRole: _role,
                                    onRoleChanged: (r) =>
                                        setState(() => _role = r),
                                    onSubmit: () {
                                      _submit();
                                    },
                                    onSocialSignIn:
                                        _applyDemoCredentialsAndSubmit,
                                    googleIconUrl: _googleIconUrl,
                                    appleIconUrl: _appleIconUrl,
                                    wide: false,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.size,
    required this.color,
    this.top,
    this.left,
    this.bottom,
    this.right,
  });

  final double size;
  final Color color;
  final double? top;
  final double? left;
  final double? bottom;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 120,
                spreadRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileBrandTop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.spa_rounded, size: 28, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'agriNXT',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginHeroPanel extends StatelessWidget {
  const _LoginHeroPanel({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.surfaceContainerLow,
              child: Icon(
                Icons.eco_rounded,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.background,
                  AppColors.background.withValues(alpha: 0.85),
                  AppColors.background.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.eco_rounded, size: 32, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'agriNXT',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The Future of',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            fontSize: 44,
                          ),
                    ),
                    Text(
                      'Smart Farming',
                      style:
                          Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                fontSize: 44,
                                color: AppColors.primaryFixedDim,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Precision data meet organic growth. Manage your field\'s health with the Digital Greenhouse lens.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginFormPanel extends StatelessWidget {
  const _LoginFormPanel({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onSubmit,
    required this.onSocialSignIn,
    required this.googleIconUrl,
    required this.appleIconUrl,
    required this.wide,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onSubmit;
  final VoidCallback onSocialSignIn;
  final String googleIconUrl;
  final String appleIconUrl;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final pad = wide ? 64.0 : 32.0;

    return Container(
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
      padding: EdgeInsets.fromLTRB(pad, wide ? 64 : 40, pad, wide ? 64 : 40),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment:
              wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment:
                  wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your credentials to access your insights.',
                  textAlign: wide ? TextAlign.start : TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: wide ? Alignment.centerLeft : Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: wide
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.stretch,
                  children: [
                    _UppercaseLabel(text: 'Role'),
                    const SizedBox(height: 8),
                    SegmentedButton<UserRole>(
                      segments: const [
                        ButtonSegment<UserRole>(
                          value: UserRole.farmer,
                          label: Text('Farmer'),
                          icon: Icon(Icons.agriculture_outlined, size: 18),
                        ),
                        ButtonSegment<UserRole>(
                          value: UserRole.lender,
                          label: Text('Lender'),
                          icon:
                              Icon(Icons.precision_manufacturing_outlined, size: 18),
                        ),
                      ],
                      selected: {selectedRole},
                      onSelectionChanged: (s) {
                        if (s.isEmpty) return;
                        onRoleChanged(s.first);
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedRole.subtitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            _UppercaseLabel(text: 'Email address'),
            const SizedBox(height: 8),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: _authInputDecoration(
                context,
                hintText: _LoginScreenState._demoEmail,
                prefixIcon: Icons.mail_outline_rounded,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter email';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _UppercaseLabel(text: 'Password')),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot?',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: _authInputDecoration(
                context,
                hintText: _LoginScreenState._demoPassword,
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onPressed: onTogglePassword,
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter password' : null,
            ),
            const SizedBox(height: 28),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: EditorialGradients.primaryCta,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSubmit,
                  borderRadius: BorderRadius.circular(9999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'SIGN IN TO DASHBOARD',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR CONTINUE WITH',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SocialPillButton(
                    label: 'Google',
                    iconUrl: googleIconUrl,
                    onPressed: onSocialSignIn,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SocialPillButton(
                    label: 'Apple',
                    iconUrl: appleIconUrl,
                    onPressed: onSocialSignIn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Sign up',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              AppColors.primary.withValues(alpha: 0.5),
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UppercaseLabel extends StatelessWidget {
  const _UppercaseLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
      ),
    );
  }
}

InputDecoration _authInputDecoration(
  BuildContext context, {
  required String hintText,
  required IconData prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
    ),
    filled: true,
    fillColor: AppColors.surfaceContainerLowest,
    contentPadding: const EdgeInsets.fromLTRB(48, 16, 16, 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: AppColors.primary.withValues(alpha: 0.4),
        width: 2,
      ),
    ),
    prefixIcon: Icon(prefixIcon, color: AppColors.onSurfaceVariant),
    suffixIcon: suffixIcon,
  );
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({
    required this.url,
    required this.label,
  });

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (label == 'Apple') {
      return Icon(
        Icons.apple,
        size: 22,
        color: AppColors.onSurface,
      );
    }
    return Image.network(
      url,
      width: 20,
      height: 20,
      errorBuilder: (_, __, ___) => Icon(
        Icons.g_mobiledata,
        size: 22,
        color: AppColors.onSurface,
      ),
    );
  }
}

class _SocialPillButton extends StatelessWidget {
  const _SocialPillButton({
    required this.label,
    required this.iconUrl,
    required this.onPressed,
  });

  final String label;
  final String iconUrl;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(
                url: iconUrl,
                label: label,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
