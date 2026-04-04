/// Base URL for [crop-disease-prediction] FastAPI (uvicorn main:app).
///
/// Examples:
/// - Android emulator: `http://10.0.2.2:8000`
/// - iOS simulator: `http://127.0.0.1:8000`
/// - Physical device: your PC LAN IP, e.g. `http://192.168.1.5:8000`
const String kBaseUrl = 'http://10.0.2.2:8000';

/// When true, disease scan skips `POST /disease/diagnose` and uses mock UI data.
/// Set to false after `uvicorn main:app` is running and `mobilenetv2_plant.pth` exists.
const bool kUseMockData = true;
