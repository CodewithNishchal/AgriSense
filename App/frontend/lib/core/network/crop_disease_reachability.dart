import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'app_config.dart';
import 'crop_disease_api_service.dart';

/// True when the device has a network interface and [kCropDiseaseHealthUrl] responds.
Future<bool> isCropDiseaseBackendReachable() async {
  try {
    final types = await Connectivity().checkConnectivity();
    final offline = types.isEmpty ||
        types.every((t) => t == ConnectivityResult.none);
    if (offline) return false;
  } catch (_) {
    return false;
  }

  try {
    final dio = createCropDiseaseDio();
    final response = await dio.get<dynamic>(
      kCropDiseaseHealthUrl,
      options: Options(
        sendTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      ),
    );
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}
