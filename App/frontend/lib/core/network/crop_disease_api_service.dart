import 'dart:io';

import 'package:dio/dio.dart';

import 'app_config.dart';
import 'dio_debug_logging.dart';

String _basename(String path) {
  final normalized = path.replaceAll('\\', '/');
  final i = normalized.lastIndexOf('/');
  return i >= 0 ? normalized.substring(i + 1) : normalized;
}

/// [Dio] with explicit timeouts (null [connectTimeout] can behave like 0s on mobile).
Dio createCropDiseaseDio() {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 45),
      sendTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    ),
  );
}

/// REST client for [crop-disease-prediction] FastAPI (`uvicorn main:app --port 8000`).
class CropDiseaseApiService {
  CropDiseaseApiService({Dio? dio}) : _dio = dio ?? createCropDiseaseDio() {
    attachDebugNetworkLogging(_dio);
  }

  final Dio _dio;

  static Options get _multipartTimeouts => Options(
        sendTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
      );

  /// Leaf image → intelligence JSON. Throws [DioException] on HTTP/network errors.
  Future<Map<String, dynamic>> predictLeaf({
    required String imagePath,
    String? textInput,
    double? locationLat,
    double? locationLon,
    double cropAreaAcres = 1.0,
    double marketPriceRsPerQuintal = 1500,
    int topK = 3,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw StateError('Image file not found: $imagePath');
    }

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imagePath,
        filename: _basename(imagePath).isNotEmpty ? _basename(imagePath) : 'leaf.jpg',
      ),
      'crop_area_acres': cropAreaAcres.toString(),
      'market_price_rs_per_quintal': marketPriceRsPerQuintal.toString(),
      'top_k': topK.toString(),
      if (textInput != null && textInput.trim().isNotEmpty)
        'text_input': textInput.trim(),
      if (locationLat != null) 'location_lat': locationLat.toString(),
      if (locationLon != null) 'location_lon': locationLon.toString(),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      kCropDiseasePredictUrl,
      data: form,
      options: _multipartTimeouts,
    );
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Empty JSON body from predict',
      );
    }
    return data;
  }

  /// Audio file → STT JSON (`transcript`, `status`, `error`, …). Throws on failure.
  Future<Map<String, dynamic>> transcribeAudio({
    required String audioPath,
    String mode = 'auto',
    String sttLanguageCode = 'en-IN',
    String sttModel = 'saarika:v2.5',
    String whisperModel = 'base',
    String? whisperLanguage,
  }) async {
    final file = File(audioPath);
    if (!await file.exists()) {
      throw StateError('Audio file not found: $audioPath');
    }

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        audioPath,
        filename: _basename(audioPath).isNotEmpty ? _basename(audioPath) : 'audio.wav',
      ),
      'mode': mode,
      'stt_language_code': sttLanguageCode,
      'stt_model': sttModel,
      'whisper_model': whisperModel,
      if (whisperLanguage != null && whisperLanguage.isNotEmpty)
        'whisper_language': whisperLanguage,
    });

    final response = await _dio.post<Map<String, dynamic>>(
      kCropDiseaseVoiceSttUrl,
      data: form,
      options: _multipartTimeouts,
    );
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Empty JSON body from voice/stt',
      );
    }
    return data;
  }

  /// Full speech pipeline (STT + Sarvam TTS). Response may include
  /// `audio_download_url` (path under `/api/v1/voice/download/...`).
  Future<Map<String, dynamic>> voicePipeline({
    required String audioPath,
    String mode = 'auto',
    String sttLanguageCode = 'en-IN',
    String sttModel = 'saarika:v2.5',
    String ttsLanguageCode = 'en-IN',
    String ttsModel = 'bulbul:v2',
    String speaker = 'anushka',
    String whisperModel = 'base',
    String? whisperLanguage,
  }) async {
    final file = File(audioPath);
    if (!await file.exists()) {
      throw StateError('Audio file not found: $audioPath');
    }

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        audioPath,
        filename: _basename(audioPath).isNotEmpty ? _basename(audioPath) : 'audio.wav',
      ),
      'mode': mode,
      'stt_language_code': sttLanguageCode,
      'stt_model': sttModel,
      'tts_language_code': ttsLanguageCode,
      'tts_model': ttsModel,
      'speaker': speaker,
      'whisper_model': whisperModel,
      if (whisperLanguage != null && whisperLanguage.isNotEmpty)
        'whisper_language': whisperLanguage,
    });

    final response = await _dio.post<Map<String, dynamic>>(
      kCropDiseaseVoicePipelineUrl,
      data: form,
      options: _multipartTimeouts,
    );
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Empty JSON body from voice/pipeline',
      );
    }
    return data;
  }

  /// Disease report JSON (from [predictLeaf]) + farmer question (text and/or audio)
  /// → Gemini using server `GEMINI_API_KEY`.
  Future<Map<String, dynamic>> chatbotAskWithDisease({
    required String diseaseJsonString,
    String? questionText,
    String? audioPath,
    String sessionId = 'ml_lab_session',
    String sttMode = 'auto',
  }) async {
    final hasQ = questionText != null && questionText.trim().isNotEmpty;
    final ap = audioPath;
    final hasAudio = ap != null && await File(ap).exists();
    if (!hasQ && !hasAudio) {
      throw StateError('Provide questionText and/or audioPath');
    }

    final map = <String, dynamic>{
      'session_id': sessionId,
      'disease_json': diseaseJsonString,
      'stt_mode': sttMode,
      if (hasQ) 'question': questionText.trim(),
    };
    if (hasAudio) {
      map['audio'] = await MultipartFile.fromFile(
        ap,
        filename: _basename(ap).isNotEmpty ? _basename(ap) : 'question.wav',
      );
    }

    final response = await _dio.post<Map<String, dynamic>>(
      kCropDiseaseChatAskWithDiseaseUrl,
      data: FormData.fromMap(map),
      options: _multipartTimeouts,
    );
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Empty JSON from chatbot/ask-with-disease',
      );
    }
    return data;
  }

  static String dioErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) {
        final d = data['detail'];
        if (d is List) {
          return d.map((e) => e.toString()).join('\n');
        }
        return d.toString();
      }
      if (data is String && data.isNotEmpty) return data;
      return error.message ?? error.toString();
    }
    return error.toString();
  }
}
