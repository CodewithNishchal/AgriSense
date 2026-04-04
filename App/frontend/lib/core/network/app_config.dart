import 'package:flutter_dotenv/flutter_dotenv.dart';

String _trimTrailingSlash(String url) {
  final t = url.trim();
  if (t.length > 1 && t.endsWith('/')) {
    return t.substring(0, t.length - 1);
  }
  return t;
}

/// Base URL for [crop-disease-prediction] FastAPI (uvicorn `main:app`, port 8000).
///
/// Resolved in order:
/// 1. `--dart-define=CROP_DISEASE_BASE_URL=...` or `BASE_URL=...`
/// 2. `assets/.env`: `CROP_DISEASE_BASE_URL` or `BASE_URL`
/// 3. Default: `http://10.0.2.2:8000` (Android emulator → host loopback)
///
/// Examples:
/// - Android emulator: `http://10.0.2.2:8000`
/// - iOS simulator: `http://127.0.0.1:8000`
/// - Physical device: `http://192.168.1.5:8000` (your PC’s LAN IP)
String get kBaseUrl {
  const fromCrop = String.fromEnvironment(
    'CROP_DISEASE_BASE_URL',
    defaultValue: '',
  );
  if (fromCrop.trim().isNotEmpty) return _trimTrailingSlash(fromCrop);
  const fromBase = String.fromEnvironment('BASE_URL', defaultValue: '');
  if (fromBase.trim().isNotEmpty) return _trimTrailingSlash(fromBase);

  final envCrop = dotenv.env['CROP_DISEASE_BASE_URL']?.trim();
  if (envCrop != null && envCrop.isNotEmpty) return _trimTrailingSlash(envCrop);
  final envBase = dotenv.env['BASE_URL']?.trim();
  if (envBase != null && envBase.isNotEmpty) return _trimTrailingSlash(envBase);

  return 'http://10.0.2.2:8000';
}

/// [crop-disease-prediction] mounts routes under this prefix (see `main.py` `API_PREFIX`).
const String kCropDiseaseApiPrefix = '/api/v1';

/// GET quick probe for scan tab (server up + network path works).
String get kCropDiseaseHealthUrl => '$kBaseUrl$kCropDiseaseApiPrefix/health';

/// POST multipart: leaf image + optional `text_input` (e.g. STT transcript).
String get kCropDiseasePredictUrl => '$kBaseUrl$kCropDiseaseApiPrefix/predict';

/// POST multipart: audio file → STT (`mode` auto/online/offline).
String get kCropDiseaseVoiceSttUrl => '$kBaseUrl$kCropDiseaseApiPrefix/voice/stt';

/// POST multipart: audio → STT → TTS; JSON may include `audio_download_url`.
String get kCropDiseaseVoicePipelineUrl =>
    '$kBaseUrl$kCropDiseaseApiPrefix/voice/pipeline';

/// POST multipart: `/predict` JSON + text and/or audio question → Gemini.
String get kCropDiseaseChatAskWithDiseaseUrl =>
    '$kBaseUrl$kCropDiseaseApiPrefix/chatbot/ask-with-disease';

/// Production: keep `false` so Scan uses your FastAPI when reachable.
/// Set `true` only for offline-only builds without a disease server.
const bool kUseMockData = false;

/// HTTPS endpoint that accepts the scan JSON (e.g. Next.js `app/api/analyze/save`).
///
/// **Do not** put [DATABASE_URL] or any Postgres credentials in the Flutter app.
/// Set via `--dart-define=ANALYZE_SAVE_API_URL=...` or `assets/.env` after
/// [dotenv.load] in [main].
String get kAnalyzeSaveApiUrl {
  const fromDefine = String.fromEnvironment(
    'ANALYZE_SAVE_API_URL',
    defaultValue: '',
  );
  if (fromDefine.trim().isNotEmpty) return fromDefine.trim();
  return dotenv.env['ANALYZE_SAVE_API_URL']?.trim() ?? '';
}
