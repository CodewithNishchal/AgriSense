import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Synthetic heatmap + chart points for preview (replace with /api/scans/heatmap).
class MockDiseaseMapData {
  MockDiseaseMapData._();

  static const districts = <String>[
    'All India',
    'Nagpur',
    'Pune',
    'Haryana',
    'Hyderabad',
  ];

  static LatLng centerFor(String district) {
    switch (district) {
      case 'Nagpur':
        return const LatLng(21.1458, 79.0882);
      case 'Pune':
        return const LatLng(18.5204, 73.8567);
      case 'Haryana':
        return const LatLng(29.0588, 76.0856);
      case 'Hyderabad':
        return const LatLng(17.3850, 78.4867);
      default:
        return const LatLng(20.5937, 78.9629);
    }
  }

  static List<CircleDatum> heatCircles(String district) {
    final c = centerFor(district);
    final seed = district.hashCode;
    final rnd = math.Random(seed);
    final out = <CircleDatum>[];
    for (var i = 0; i < 42; i++) {
      final dx = (rnd.nextDouble() - 0.5) * (district == 'All India' ? 8.0 : 1.2);
      final dy = (rnd.nextDouble() - 0.5) * (district == 'All India' ? 8.0 : 1.2);
      final risk = rnd.nextDouble();
      out.add(
        CircleDatum(
          LatLng(c.latitude + dx, c.longitude + dy),
          radius: 6 + rnd.nextDouble() * 14,
          colorTier: risk > 0.65
              ? 2
              : risk > 0.35
                  ? 1
                  : 0,
        ),
      );
    }
    return out;
  }

  /// KPI values (synthetic).
  static Map<String, String> kpis(String district) {
    final m = district.hashCode.abs() % 97;
    return {
      'scans': '${12400 + m * 13}',
      'active': '${180 + m}',
      'risk': '₹${(2.4 + m * 0.01).toStringAsFixed(1)}Cr',
      'officers': '${42 + m % 20}',
    };
  }

  /// 14 points: historical cases vs model forecast.
  static ({List<double> historical, List<double> forecast}) chartSeries(
    String district,
  ) {
    final rnd = math.Random(district.hashCode);
    final hist = <double>[];
    final fore = <double>[];
    var base = 20 + rnd.nextDouble() * 15;
    for (var i = 0; i < 14; i++) {
      base += (rnd.nextDouble() - 0.45) * 6;
      hist.add(base.clamp(5, 120));
      fore.add((base + rnd.nextDouble() * 8 + i * 0.8).clamp(5, 140));
    }
    return (historical: hist, forecast: fore);
  }
}

class CircleDatum {
  CircleDatum(this.center, {required this.radius, required this.colorTier});

  final LatLng center;
  final double radius;
  /// 0 = low, 1 = emerging, 2 = high density
  final int colorTier;
}
