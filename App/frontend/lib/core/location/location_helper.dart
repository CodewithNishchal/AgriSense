import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Device location without calling your API — for UI labels and future /api/analyze.
class LocationHelper {
  LocationHelper._();

  static Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  static Future<LocationPermission> checkPermission() =>
      Geolocator.checkPermission();

  static Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  /// OS permission dialog (when in doubt).
  static Future<bool> requestWhenInUse() async {
    final s = await Permission.locationWhenInUse.request();
    return s.isGranted;
  }

  static Future<Position?> getCurrentPosition() async {
    var p = await checkPermission();
    if (p == LocationPermission.denied) {
      p = await requestPermission();
    }
    if (p == LocationPermission.deniedForever ||
        p == LocationPermission.denied) {
      return null;
    }
    if (!await isServiceEnabled()) return null;
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
  }

  static String formatPosition(Position? pos) {
    if (pos == null) return 'Location unavailable';
    return '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
  }
}
