import 'label_mapping.dart';

/// Optional richer copy keyed by **model class index** (same order as `plant_village_labels.dart`).
///
/// Index 0 is `Apple___Apple_scab`, not “healthy” — do not use wrong indices here.
final Map<int, Map<String, dynamic>> diseaseDatabase = {
  7: {
    'diseaseName': 'Gray Leaf Spot',
    'crop': 'Corn',
    'severity': 'High',
    'precautions': [
      'Practice crop rotation; do not plant corn in the same field consecutively.',
      'Clear away previous crop debris.',
      'Apply foliar fungicides during early tasseling stages.',
    ],
  },
};

List<String> _defaultOfflinePrecautions({required bool isHealthy}) {
  if (isHealthy) {
    return [
      'Plant looks healthy. Keep up watering, nutrition, and scouting.',
    ];
  }
  return [
    'Monitor affected plants and nearby rows every few days.',
    'Consult your local extension office for region-specific treatment.',
    'Avoid working wet foliage to reduce spread.',
  ];
}

/// Label mapping (argmax index → PlantVillage key) + optional [diseaseDatabase] overrides.
Map<String, dynamic> buildOfflineTfliteResultExtra({
  required int classIndex,
  required double confidenceRaw,
  required String imagePath,
  required String scanTimeDisplay,
  String? locationLabel,
  double? lat,
  double? lon,
}) {
  final key = diseaseKeyAtIndex(classIndex);
  if (key == null) {
    throw ArgumentError.value(
      classIndex,
      'classIndex',
      'Out of range for kPlantVillage38ClassLabels (0–37).',
    );
  }

  final readable = formatPlantVillageLabelKey(key);
  final isHealthy = plantVillageKeyIsHealthy(key);
  final dbRow = diseaseDatabase[classIndex];

  final crop = (dbRow?['crop'] as String?) ?? cropFromPlantVillageKey(key);
  final severity =
      (dbRow?['severity'] as String?) ?? (isHealthy ? 'None' : 'Review recommended');
  final precautions = dbRow != null
      ? (dbRow['precautions'] as List<dynamic>).map((e) => e.toString()).toList()
      : _defaultOfflinePrecautions(isHealthy: isHealthy);

  final firstAid =
      precautions.isNotEmpty ? precautions.first : 'Follow the action plan below.';
  final buf = StringBuffer(firstAid);
  if (precautions.length > 1) {
    buf.writeln();
    for (final p in precautions.skip(1)) {
      buf.writeln('• $p');
    }
  }

  final sevUpper = severity.toUpperCase();
  final conf01 = confidenceRaw > 1.0
      ? (confidenceRaw / 100.0).clamp(0.0, 1.0)
      : confidenceRaw.clamp(0.0, 1.0);
  final confPct = (conf01 * 100).clamp(0.0, 100.0);

  final report = <String, dynamic>{
    'disease': readable,
    'disease_key': key,
    'crop': crop,
    'confidence': confPct,
    'confidence_raw': conf01,
    'severity': severity,
    'severity_level': sevUpper,
    'first_aid': firstAid,
    'action_plan': precautions,
    'location': <String, dynamic>{'lat': lat, 'lon': lon},
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'scan_time_display': scanTimeDisplay,
    'offline_tflite': true,
    'class_index': classIndex,
    'is_positive': !isHealthy,
    'disease_type': isHealthy ? 'healthy' : 'disease',
    'label_readable': readable,
  };

  return {
    'diseaseName': readable,
    'confidence': conf01,
    'treatment': buf.toString().trim(),
    'remediationSteps': precautions,
    'imagePath': imagePath,
    'locationLabel': locationLabel,
    'fullReport': report,
  };
}

/// Builds [GoRoute] extra for [DiseaseResultScreen] from offline TFLite + [diseaseDatabase].
Map<String, dynamic> buildOfflineDiseaseNavExtra({
  required Map<String, dynamic> dbRow,
  required int classIndex,
  required double confidenceRaw,
  required String imagePath,
  required String scanTimeDisplay,
  String? locationLabel,
  double? lat,
  double? lon,
}) {
  final precautions = (dbRow['precautions'] as List<dynamic>)
      .map((e) => e.toString())
      .toList();
  final diseaseName = dbRow['diseaseName'] as String;
  final crop = dbRow['crop'] as String;
  final severity = dbRow['severity'] as String;
  final diseaseLine = '$crop — $diseaseName';
  final firstAid =
      precautions.isNotEmpty ? precautions.first : 'Follow the action plan below.';
  final buf = StringBuffer(firstAid);
  if (precautions.length > 1) {
    buf.writeln();
    for (final p in precautions.skip(1)) {
      buf.writeln('• $p');
    }
  }
  final sevUpper = severity.toUpperCase();
  final isHealthy = sevUpper == 'NONE' || diseaseName.toLowerCase().contains('healthy');
  final report = <String, dynamic>{
    'disease': diseaseLine,
    'disease_key': 'offline_tflite_$classIndex',
    'crop': crop,
    'confidence': (confidenceRaw * 100).clamp(0.0, 100.0),
    'confidence_raw': confidenceRaw,
    'severity': severity,
    'severity_level': sevUpper,
    'first_aid': firstAid,
    'action_plan': precautions,
    'location': <String, dynamic>{'lat': lat, 'lon': lon},
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'scan_time_display': scanTimeDisplay,
    'offline_tflite': true,
    'class_index': classIndex,
    'is_positive': !isHealthy,
    'disease_type': isHealthy ? 'healthy' : 'disease',
  };

  return {
    'diseaseName': diseaseLine,
    'confidence': confidenceRaw.clamp(0.0, 1.0),
    'treatment': buf.toString().trim(),
    'remediationSteps': precautions,
    'imagePath': imagePath,
    'locationLabel': locationLabel,
    'fullReport': report,
  };
}
