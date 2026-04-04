import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Labeled text field with leading icon (auth forms).
class AuthIconField extends StatelessWidget {
  const AuthIconField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffix,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.outlineVariant),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.fromLTRB(48, 16, 16, 16),
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
            prefixIcon: Icon(icon, color: AppColors.outlineVariant),
            suffixIcon: suffix,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
