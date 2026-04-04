import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/app_breakpoints.dart';
import '../../core/session/user_prefs.dart';
import '../../core/session/user_role.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/editorial_gradients.dart';
import '../../core/widgets/editorial_screen_background.dart';
import 'auth_editorial_side.dart';
import 'auth_icon_field.dart';

/// Sign up — layout aligned with Tailwind reference (editorial left + form right).
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  UserRole _role = UserRole.farmer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await UserPrefs.instance.setRole(_role);
    if (!context.mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= AppBreakpoint.authSplit;
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(
                  flex: 1,
                  child: AuthEditorialSide(),
                ),
                Expanded(
                  flex: 1,
                  child: ColoredBox(
                    color: AppColors.surfaceContainerLowest.withValues(alpha: 0.82),
                    child: _SignupFormColumn(
                      formKey: _formKey,
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      selectedRole: _role,
                      onRoleChanged: (r) => setState(() => _role = r),
                      onSubmit: _submit,
                      showMobileBrand: false,
                    ),
                  ),
                ),
              ],
            );
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              const Positioned.fill(child: EditorialScreenBackground()),
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: _SignupFormColumn(
                    formKey: _formKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    onTogglePassword: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    selectedRole: _role,
                    onRoleChanged: (r) => setState(() => _role = r),
                    onSubmit: _submit,
                    showMobileBrand: true,
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

class _SignupFormColumn extends StatelessWidget {
  const _SignupFormColumn({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onSubmit,
    required this.showMobileBrand,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;
  final Future<void> Function() onSubmit;
  final bool showMobileBrand;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final pad = w >= AppBreakpoint.md ? 64.0 : 24.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 24, pad, 32),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showMobileBrand) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.spa_rounded, size: 32, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'AgriSense',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
            Text(
              'Create your account',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your details to start monitoring your field.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Role',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
            ),
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
                  icon: Icon(Icons.precision_manufacturing_outlined, size: 18),
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
            const SizedBox(height: 28),
            AuthIconField(
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
              controller: nameController,
              hint: 'Full name',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            const SizedBox(height: 20),
            AuthIconField(
              label: 'Email Address',
              icon: Icons.mail_outline_rounded,
              controller: emailController,
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter email';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Password',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: '8+ characters',
                hintStyle: TextStyle(color: AppColors.outlineVariant),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                contentPadding: const EdgeInsets.fromLTRB(48, 16, 48, 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.outlineVariant,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.outlineVariant,
                  ),
                  onPressed: onTogglePassword,
                ),
              ),
              validator: (v) {
                if (v == null || v.length < 8) {
                  return 'At least 8 characters';
                }
                final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v);
                if (!hasSpecial) return 'Add one special character';
                return null;
              },
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Must be at least 8 characters with one special symbol.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.outlineVariant,
                      fontSize: 11,
                    ),
              ),
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
                  onTap: () {
                    onSubmit();
                  },
                  borderRadius: BorderRadius.circular(9999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'CREATE ACCOUNT',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.onPrimaryFixed,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'SECURE PROCESSING',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.outlineVariant,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton.icon(
                onPressed: () => context.go('/login'),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
                label: Text(
                  'Back to Login',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'By creating an account, you agree to our',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.outlineVariant,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 4),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Terms of Service',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurface,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                  ),
                ),
                Text(
                  ' and ',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.outlineVariant,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Privacy Policy',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurface,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary.withValues(alpha: 0.3),
                        ),
                  ),
                ),
                Text(
                  '.',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.outlineVariant,
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
