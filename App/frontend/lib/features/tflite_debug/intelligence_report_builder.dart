import 'dart:convert';

import 'package:flutter/services.dart';

import '../disease_detection/data/label_mapping.dart';
import '../disease_detection/data/plant_village_labels.dart';

/// Layer 2–style report: protocols JSON + validation rules (simplified from Colab `onlinemodel.py`).
abstract final class IntelligenceReportBuilder {
  static Map<String, dynamic>? _root;

  static Future<void> ensureLoaded() async {
    if (_root != null) return;
    final raw = await rootBundle.loadString('assets/data/disease_protocols.json');
    _root = jsonDecode(raw) as Map<String, dynamic>;
  }

  static Map<String, dynamic> _detectContext(String diseaseKey) {
    final k = diseaseKey.toLowerCase();
    const fungal = [
      'blight',
      'mold',
      'scab',
      'mildew',
      'rot',
      'spot',
      'rust',
      'esca',
      'measles',
      'scorch',
    ];
    const viral = ['virus', 'viral', 'curl', 'mosaic', 'greening', 'haunglongbing'];
    const bacterial = ['bacterial'];
    const pest = ['mite', 'spider'];

    if (k.contains('healthy')) {
      return {'is_healthy': true, 'disease_type': 'healthy', 'bio_weight': 0.0};
    }
    if (viral.any(k.contains)) {
      return {'is_healthy': false, 'disease_type': 'viral', 'bio_weight': 1.25};
    }
    if (bacterial.any(k.contains)) {
      return {'is_healthy': false, 'disease_type': 'bacterial', 'bio_weight': 1.10};
    }
    if (pest.any(k.contains)) {
      return {'is_healthy': false, 'disease_type': 'pest', 'bio_weight': 0.90};
    }
    if (fungal.any(k.contains)) {
      return {'is_healthy': false, 'disease_type': 'fungal', 'bio_weight': 1.00};
    }
    return {'is_healthy': false, 'disease_type': 'unknown', 'bio_weight': 0.85};
  }

  static (String, String) _deriveSeverity(
    bool isHealthy,
    double bioWeight,
    double confidence,
  ) {
    if (isHealthy) return ('✅ NONE', 'NONE');
    final eff = confidence * bioWeight;
    if (eff >= 0.85) {
      return (
        '🔴 HIGH — Significant risk. Immediate intervention required.',
        'HIGH',
      );
    }
    if (eff >= 0.55) {
      return (
        '🟡 MEDIUM — Moderate risk. Treat within 48 hours and monitor daily.',
        'MEDIUM',
      );
    }
    return (
      '🟢 LOW — Early-stage detection. Preventive treatment advised.',
      'LOW',
    );
  }

  static String _weatherAdvice(String diseaseKey, double? lat, double? lon) {
    final k = diseaseKey.toLowerCase();
    if (k.contains('healthy')) {
      return '☀️ Plant is healthy. Continue monitoring. Track weather for disease-favorable conditions.';
    }
    const fungal = [
      'blight',
      'mold',
      'scab',
      'mildew',
      'rot',
      'spot',
      'rust',
    ];
    const viral = ['virus', 'viral', 'curl', 'mosaic'];
    const pest = ['mite', 'spider'];
    if (fungal.any(k.contains)) {
      return '🌧️ Fungal diseases thrive in humid/wet conditions. Spray early morning (6–9 AM). Avoid spraying if rain expected within 4 hours.';
    }
    if (viral.any(k.contains)) {
      return '🦟 Viral disease — spread by insect vectors (whiteflies/aphids). Install yellow sticky traps. Spray insecticide in evening.';
    }
    if (pest.any(k.contains)) {
      return '🌡️ Spider mites thrive in hot, dry weather. Increase irrigation. Spray miticide in early morning.';
    }
    if (lat == null || lon == null) {
      return '📍 Add GPS coordinates for personalized weather advice.';
    }
    return '🌤️ Apply treatments in calm, dry conditions. Early morning or late evening is best.';
  }

  static List<Map<String, dynamic>> _topK(List<double> raw, int k) {
    final entries = <MapEntry<int, double>>[];
    for (var i = 0; i < raw.length; i++) {
      entries.add(MapEntry(i, raw[i]));
    }
    entries.sort((a, b) => b.value.compareTo(a.value));
    final out = <Map<String, dynamic>>[];
    var rank = 1;
    for (final e in entries.take(k)) {
      final key = e.key >= 0 && e.key < kPlantVillage38ClassLabels.length
          ? kPlantVillage38ClassLabels[e.key]
          : 'unknown_index_${e.key}';
      final pct = (e.value * 100);
      out.add({
        'rank': rank++,
        'disease_key': key,
        'confidence': double.parse(pct.toStringAsFixed(2)),
      });
    }
    return out;
  }

  static Map<String, dynamic> _fallbackProtocol(String diseaseKey) {
    return {
      'display_name': formatPlantVillageLabelKey(diseaseKey),
      'crop': cropFromPlantVillageKey(diseaseKey),
      'first_aid':
          'Consult your local agricultural extension for treatment options specific to this finding.',
      'action_plan': [
        'Re-scan with a clearer, well-lit photo of the affected leaf',
        'Monitor spread to neighboring plants over 48–72 hours',
      ],
      'yield_loss_pct': 15,
      'economic_loss_per_acre_rs': 8000,
      'marketplace': {
        'recommended_products': [
          'Consult KVK for crop-specific chemistry',
          'Balanced NPK as per soil test',
        ],
        'product_type': 'Expert consult',
      },
    };
  }

  static Map<String, dynamic> _validate(
    Map<String, dynamic> result,
    Map<String, dynamic> context,
    double confidenceRaw,
  ) {
    final isHealthy = context['is_healthy'] as bool;
    final bioWeight = (context['bio_weight'] as num).toDouble();
    final (sevStr, sevLevel) = _deriveSeverity(isHealthy, bioWeight, confidenceRaw);
    result['severity'] = sevStr;
    result['severity_level'] = sevLevel;

    if (isHealthy) {
      result['first_aid'] =
          '✅ No treatment required. Your plant is healthy. '
          'Continue regular monitoring and maintain good agronomic practices.';
      const prevKw = [
        'monitor',
        'inspect',
        'preventive',
        'prevent',
        'continue',
        'maintain',
        'prune',
        'mulch',
        'rotation',
        'certified',
        'irrigation',
      ];
      final plan = (result['action_plan'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
      var cleaned = plan
          .where(
            (s) => prevKw.any((k) => s.toLowerCase().contains(k)),
          )
          .toList();
      if (cleaned.isEmpty) {
        cleaned = [
          'Continue weekly field monitoring for early disease detection',
          'Apply preventive neem-based spray before monsoon season',
          'Maintain proper plant spacing and drainage for air circulation',
          'Use balanced NPK fertilizer to maintain plant immunity',
        ];
      }
      result['action_plan'] = cleaned;
      final mp = Map<String, dynamic>.from(result['marketplace'] as Map);
      mp['product_type'] = 'Preventive';
      mp['note'] =
          'No immediate purchase required. Optional preventive measures only.';
      result['marketplace'] = mp;
      result['yield_loss_pct'] = 0;
      result['economic_loss_rs'] = 0.0;
      result['economic_loss_per_acre'] = 0.0;
    } else {
      if (confidenceRaw >= 0.70 && confidenceRaw < 0.95) {
        final caveat =
            ' [Confidence: ${(confidenceRaw * 100).toStringAsFixed(1)}% — Monitor closely. '
            'Consider re-scanning with a clearer image to confirm.]';
        result['first_aid'] =
            '${result['first_aid'].toString().replaceAll(RegExp(r'\.?$'), '')}$caveat';
      } else if (confidenceRaw < 0.70) {
        result['first_aid'] =
            '⚠️ LOW CONFIDENCE (${(confidenceRaw * 100).toStringAsFixed(1)}%): Model is uncertain. '
            'Take another photo with better lighting. Consult local agricultural officer '
            'before applying any chemicals. | ${result['first_aid']}';
        result['action_plan'] = [
          'Re-scan with a clearer, well-lit photo of the affected leaf',
          'Consult Krishi Vigyan Kendra expert (KVK Helpline: 1800-180-1551)',
          ...(result['action_plan'] as List<dynamic>).map((e) => e.toString()),
        ];
      }
      final yl = result['yield_loss_pct'] as int? ?? 0;
      if (yl == 0) {
        final floor = {'LOW': 5, 'MEDIUM': 20, 'HIGH': 40};
        result['yield_loss_pct'] = floor[sevLevel] ?? 10;
      }
      if ((result['economic_loss_rs'] as num?)?.toDouble() == 0 &&
          (result['yield_loss_pct'] as int) > 0) {
        final y = result['yield_loss_pct'] as int;
        result['economic_loss_rs'] = (y * 1000).roundToDouble();
        result['economic_loss_per_acre'] = result['economic_loss_rs'];
      }
    }

    return result;
  }

  /// Full intelligence payload matching the Colab JSON shape (for UI + optional API).
  static Future<Map<String, dynamic>> build({
    required String diseaseKey,
    required double confidenceRaw,
    required List<double> rawOutput,
    int topK = 3,
    double? lat,
    double? lon,
    double cropAreaAcres = 1.0,
    double marketPriceRsPerQuintal = 1500.0,
  }) async {
    await ensureLoaded();
    final protocols =
        _root!['protocols'] as Map<String, dynamic>;
    final protocol = protocols.containsKey(diseaseKey)
        ? Map<String, dynamic>.from(protocols[diseaseKey]! as Map)
        : _fallbackProtocol(diseaseKey);

    final context = _detectContext(diseaseKey);
    final baseLoss =
        (protocol['economic_loss_per_acre_rs'] as num?)?.toDouble() ?? 0.0;
    final adjusted = baseLoss * (marketPriceRsPerQuintal / 1500.0);
    final totalLoss = adjusted * cropAreaAcres;

    final mp = Map<String, dynamic>.from(
      protocol['marketplace'] as Map? ?? {},
    );
    if (!mp.containsKey('note')) {
      mp['note'] =
          'Contact your nearest Krishi Seva Kendra or AgriShop for availability.';
    }

    var result = <String, dynamic>{
      'disease': protocol['display_name'],
      'disease_key': diseaseKey,
      'crop': protocol['crop'],
      'confidence': double.parse((confidenceRaw * 100).toStringAsFixed(2)),
      'confidence_raw': double.parse(confidenceRaw.toStringAsFixed(6)),
      'severity': '',
      'severity_level': '',
      'first_aid': protocol['first_aid'],
      'action_plan':
          (protocol['action_plan'] as List<dynamic>).map((e) => e.toString()).toList(),
      'weather_advice': _weatherAdvice(diseaseKey, lat, lon),
      'yield_loss_pct': protocol['yield_loss_pct'] ?? 0,
      'economic_loss_rs': double.parse(totalLoss.toStringAsFixed(2)),
      'economic_loss_per_acre': double.parse(adjusted.toStringAsFixed(2)),
      'marketplace': mp,
      'location': {'lat': lat, 'lon': lon},
      'timestamp': '${DateTime.now().toUtc().toIso8601String()}Z',
      'is_positive': !(context['is_healthy'] as bool),
      'disease_type': context['disease_type'],
      'top_k_predictions': _topK(rawOutput, topK),
    };

    result = _validate(result, context, confidenceRaw);
    return result;
  }
}
