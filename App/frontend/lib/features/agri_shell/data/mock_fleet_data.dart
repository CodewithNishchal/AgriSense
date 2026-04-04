import 'package:latlong2/latlong.dart';

enum FleetPinStatus { available, rented, maintenance }

class FleetPin {
  const FleetPin({
    required this.id,
    required this.position,
    required this.label,
    required this.status,
  });

  final String id;
  final LatLng position;
  final String label;
  final FleetPinStatus status;
}

class FleetLedgerRow {
  FleetLedgerRow({
    required this.renter,
    required this.asset,
    required this.startsAt,
    required this.endsAt,
  });

  final String renter;
  final String asset;
  final DateTime startsAt;
  final DateTime endsAt;

  double progressFraction(DateTime now) {
    final t = endsAt.difference(startsAt).inMilliseconds;
    if (t <= 0) return 1;
    final e = now.difference(startsAt).inMilliseconds.clamp(0, t);
    return e / t;
  }

  Duration remaining(DateTime now) {
    final d = endsAt.difference(now);
    return d.isNegative ? Duration.zero : d;
  }
}

class MockFleetData {
  MockFleetData._();

  static Map<String, String> overview = {
    'units': '18',
    'revenue': '₹42,800',
    'utilization': '76%',
  };

  static final pins = <FleetPin>[
    FleetPin(
      id: '1',
      position: const LatLng(21.15, 79.09),
      label: 'Tractor 45HP',
      status: FleetPinStatus.rented,
    ),
    FleetPin(
      id: '2',
      position: const LatLng(21.18, 79.12),
      label: 'Sprayer 600L',
      status: FleetPinStatus.available,
    ),
    FleetPin(
      id: '3',
      position: const LatLng(21.11, 79.05),
      label: 'Harvester',
      status: FleetPinStatus.maintenance,
    ),
    FleetPin(
      id: '4',
      position: const LatLng(21.20, 79.02),
      label: 'Rotavator',
      status: FleetPinStatus.rented,
    ),
  ];

  static List<FleetLedgerRow> ledger() {
    final now = DateTime.now();
    return [
      FleetLedgerRow(
        renter: 'Ramesh K.',
        asset: 'Tractor 45HP',
        startsAt: now.subtract(const Duration(minutes: 18)),
        endsAt: now.add(const Duration(minutes: 42)),
      ),
      FleetLedgerRow(
        renter: 'Co-op North',
        asset: 'Sprayer 600L',
        startsAt: now.subtract(const Duration(minutes: 45)),
        endsAt: now.add(const Duration(hours: 2, minutes: 15)),
      ),
      FleetLedgerRow(
        renter: 'Vijay S.',
        asset: 'Rotavator',
        startsAt: now.subtract(const Duration(minutes: 12)),
        endsAt: now.add(const Duration(minutes: 8)),
      ),
    ];
  }

  static List<TelematicsAlert> alerts() => const [
    TelematicsAlert(
      title: 'Geofence exit',
      detail: 'Harvester #3 left designated block near Wardha Rd.',
      severity: 1,
    ),
    TelematicsAlert(
      title: 'Engine temperature',
      detail: 'Tractor 45HP reported coolant high — schedule check.',
      severity: 2,
    ),
  ];
}

class TelematicsAlert {
  const TelematicsAlert({
    required this.title,
    required this.detail,
    required this.severity,
  });

  final String title;
  final String detail;
  final int severity;
}
