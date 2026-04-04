import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/editorial_gradients.dart';

/// Primary CTA with 135° gradient; pill shape ([design.md]).
class EditorialPrimaryButton extends StatelessWidget {
  const EditorialPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(9999),
          child: Ink(
            decoration: BoxDecoration(
              gradient: disabled ? null : EditorialGradients.primaryCta,
              color: disabled ? AppColors.surfaceContainerHighest : null,
              borderRadius: BorderRadius.circular(9999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: AppColors.onPrimaryFixed),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.onPrimaryFixed,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
