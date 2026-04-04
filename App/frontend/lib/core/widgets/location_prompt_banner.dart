import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../location/location_helper.dart';
import '../session/user_prefs.dart';
import '../theme/app_colors.dart';

/// One-time prompt to enable device location (no API call).
class LocationPromptBanner extends StatefulWidget {
  const LocationPromptBanner({super.key});

  @override
  State<LocationPromptBanner> createState() => _LocationPromptBannerState();
}

class _LocationPromptBannerState extends State<LocationPromptBanner> {
  bool _loading = false;
  String? _status;

  Future<void> _request() async {
    setState(() {
      _loading = true;
      _status = null;
    });
    final ok = await LocationHelper.requestWhenInUse();
    if (!mounted) return;
    if (ok) {
      final pos = await LocationHelper.getCurrentPosition();
      if (!mounted) return;
      await UserPrefs.instance.setLocationPromptCompleted();
      setState(() {
        _loading = false;
        _status = pos != null
            ? 'Using ${LocationHelper.formatPosition(pos)}'
            : 'Permission granted — enable GPS for coordinates.';
      });
    } else {
      setState(() {
        _loading = false;
        _status = 'Location denied — you can enable it in system settings.';
      });
    }
  }

  Future<void> _dismiss() async {
    await UserPrefs.instance.setLocationPromptCompleted();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (UserPrefs.instance.locationPromptCompleted) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: AppColors.surfaceContainer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Field-ready location',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: _dismiss,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Not now',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Allow location so scans and advisories can attach coordinates later (/api/analyze).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              if (_status != null) ...[
                const SizedBox(height: 8),
                Text(
                  _status!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loading ? null : _request,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded, size: 20),
                label: Text(_loading ? 'Requesting…' : 'Allow while using app'),
              ),
              TextButton(
                onPressed: () async {
                  await openAppSettings();
                },
                child: const Text('Open app settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
