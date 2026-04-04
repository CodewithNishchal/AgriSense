import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/editorial_asset_urls.dart';

/// Left column: hero image, agriNXT branding, glass stat cards (matches HTML reference).
class AuthEditorialSide extends StatelessWidget {
  const AuthEditorialSide({super.key});

  @override
  Widget build(BuildContext context) {
    final headline = Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          height: 1.1,
          letterSpacing: -0.5,
        );

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.4,
            child: Image.network(
              EditorialAssetUrls.signupEditorial,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surfaceContainerLow,
                child: Icon(
                  Icons.landscape_rounded,
                  size: 120,
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.surfaceContainerLowest.withValues(alpha: 0.3),
                AppColors.background.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.spa_rounded, size: 48, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'agriNXT',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: AppColors.primary,
                          fontSize: 32,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Cultivate precision from the ground up.',
                style: headline,
              ),
              const SizedBox(height: 16),
              Text(
                'Join a network of smart farms utilizing real-time soil intelligence and atmospheric data to maximize yield and sustainability.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 18,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _GlassStat(value: '98%', label: 'Efficiency Increase')),
                  const SizedBox(width: 16),
                  Expanded(child: _GlassStat(value: '12k+', label: 'Active Fields')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlassStat extends StatelessWidget {
  const _GlassStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0x99121410),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 28,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 2,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
