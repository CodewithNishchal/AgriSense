import 'dart:io';

import 'package:dio/dio.dart';

import 'app_config.dart';

/// Calls [crop-disease-prediction] FastAPI `POST /disease/diagnose`.
/// On failure or when [kUseMockData] is true, returns null so UI can use mock.
class DiseaseDiagnosisService {
  DiseaseDiagnosisService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Demo payload matching the notebook / FastAPI intelligence report shape.
  static Map<String, dynamic> demoReportPayload({double? lat, double? lon}) {
    final ts = DateTime.now().toUtc().toIso8601String();
    return <String, dynamic>{
      'disease': 'Healthy Tomato',
      'disease_key': 'Tomato___healthy',
      'crop': 'Tomato',
      'confidence': 99.81,
      'confidence_raw': 0.998073,
      'severity': '✅ NONE',
      'severity_level': 'NONE',
      'first_aid':
          '✅ No treatment required. Your plant is healthy. Continue regular monitoring and maintain good agronomic practices.',
      'action_plan': <String>[
        'Continue monitoring every 3–4 days',
        'Apply preventive Mancozeb spray before monsoon',
        'Maintain proper calcium-boron nutrition to prevent BER',
      ],
      'weather_advice':
          '☀️ Plant is healthy. Continue monitoring. Track weather for disease-favorable conditions.',
      'yield_loss_pct': 0,
      'economic_loss_rs': 0.0,
      'economic_loss_per_acre': 0.0,
      'marketplace': <String, dynamic>{
        'recommended_products': <String>[
          'NPK 12-32-16',
          'Calcium Nitrate',
          'Mancozeb (preventive)',
        ],
        'product_type': 'Preventive',
        'note': 'No immediate purchase required. Optional preventive measures only.',
      },
      'location': <String, dynamic>{
        'lat': lat,
        'lon': lon,
      },
      'timestamp': ts,
      'is_positive': false,
      'disease_type': 'healthy',
      'top_k_predictions': <Map<String, dynamic>>[
        <String, dynamic>{
          'rank': 1,
          'disease_key': 'Tomato___healthy',
          'confidence': 99.81,
        },
        <String, dynamic>{
          'rank': 2,
          'disease_key': 'Tomato___Target_Spot',
          'confidence': 0.13,
        },
        <String, dynamic>{
          'rank': 3,
          'disease_key': 'Tomato___Spider_mites Two-spotted_spider_mite',
          'confidence': 0.06,
        },
      ],
    };
  }

  /// Returns parsed JSON map or null if skipped / failed.
  Future<Map<String, dynamic>?> diagnoseFromFile({
    required String imagePath,
    double? lat,
    double? lon,
    double cropAreaAcres = 1.0,
    double marketPriceRsPerQuintal = 1500,
    int topK = 3,
    String? voiceTranscript,
  }) async {
    if (kUseMockData) return null;

    final file = File(imagePath);
    if (!await file.exists()) return null;

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath, filename: 'leaf.jpg'),
      'crop_area_acres': cropAreaAcres.toString(),
      'market_price_rs_per_quintal': marketPriceRsPerQuintal.toString(),
      'top_k': topK.toString(),
      if (lat != null) 'lat': lat.toString(),
      if (lon != null) 'lon': lon.toString(),
      if (voiceTranscript != null && voiceTranscript.isNotEmpty)
        'voice_transcript': voiceTranscript,
    });

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$kBaseUrl/disease/diagnose',
        data: form,
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      return response.data;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Maps API JSON to navigation extra for [DiseaseResultScreen].
  static Map<String, dynamic> toResultExtra(Map<String, dynamic> api) {
    final conf = api['confidence'];
    final confRaw = api['confidence_raw'];
    double c = 0.85;
    if (confRaw is num) {
      c = confRaw.toDouble();
    } else if (conf is num) {
      c = conf.toDouble() / 100.0;
    }

    final firstAid = api['first_aid']?.toString() ?? '';
    final plan = api['action_plan'];
    String treatment = firstAid;
    List<String>? steps;
    if (plan is List) {
      steps = plan.map((e) => e.toString()).toList();
      treatment = '$firstAid\n\n${steps.map((e) => '• $e').join('\n')}';
    }

    return {
      'diseaseName': api['disease']?.toString() ?? 'Unknown',
      'confidence': c.clamp(0.0, 1.0),
      'treatment': treatment.trim().isEmpty ? 'No treatment text returned.' : treatment.trim(),
      'remediationSteps': steps,
      'imagePath': null,
      'fullReport': api,
    };
  }
}
