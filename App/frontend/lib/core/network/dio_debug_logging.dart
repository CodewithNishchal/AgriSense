import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// In debug/profile, attaches [LogInterceptor] once so `flutter run` shows
/// crop-disease API traffic in the terminal.
void attachDebugNetworkLogging(Dio dio) {
  if (!kDebugMode) return;
  final already = dio.interceptors.any((e) => e is LogInterceptor);
  if (already) return;
  dio.interceptors.add(
    LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ),
  );
}
