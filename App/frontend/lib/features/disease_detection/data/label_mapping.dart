import 'plant_village_labels.dart';

/// Human-readable line: `Tomato___Early_blight` → `Tomato — Early blight`.
String formatPlantVillageLabelKey(String diseaseKey) {
  if (!diseaseKey.contains('___')) {
    return diseaseKey.replaceAll('_', ' ').trim();
  }
  return diseaseKey
      .split('___')
      .map((s) => s.replaceAll('_', ' ').trim())
      .join(' — ');
}

bool plantVillageKeyIsHealthy(String diseaseKey) {
  return diseaseKey.toLowerCase().contains('healthy');
}

/// Crop segment before `___`, underscores → spaces.
String cropFromPlantVillageKey(String diseaseKey) {
  final i = diseaseKey.indexOf('___');
  if (i <= 0) return 'Unknown';
  return diseaseKey.substring(0, i).replaceAll('_', ' ').trim();
}

String? diseaseKeyAtIndex(int classIndex) {
  if (classIndex < 0 || classIndex >= kPlantVillage38ClassLabels.length) {
    return null;
  }
  return kPlantVillage38ClassLabels[classIndex];
}
