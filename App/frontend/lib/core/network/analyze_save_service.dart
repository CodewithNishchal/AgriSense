import 'package:dio/dio.dart';

import '../debug/terminal_log.dart';
import 'analyze_save_url.dart';
import 'app_config.dart';

void _logAnalyzeSave(String message) {
  logToTerminal('AnalyzeSave', message);
}

/// POSTs the on-device diagnostic payload to [kAnalyzeSaveApiUrl] (backend inserts into Postgres).
class AnalyzeSaveService {
  AnalyzeSaveService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Ensures fields expected by a typical `INSERT INTO disease_scans (...)` API exist.
  static Map<String, dynamic> ensureApiShape(Map<String, dynamic> payload) {
    final out = Map<String, dynamic>.from(payload);
    final locRaw = out['location'];
    final loc = <String, dynamic>{};
    if (locRaw is Map) {
      for (final e in locRaw.entries) {
        loc[e.key.toString()] = e.value;
      }
    }
    loc['lat'] ??= null;
    loc['lon'] ??= null;
    out['location'] = loc;

    out['timestamp'] ??=
        DateTime.now().toUtc().toIso8601String();

    out['disease_key'] ??=
        out['disease']?.toString() ?? 'unknown';

    if (out['confidence_raw'] == null) {
      final c = out['confidence'];
      if (c is num) {
        out['confidence_raw'] = c > 1 ? c / 100.0 : c.toDouble();
      } else {
        out['confidence_raw'] = 0.0;
      }
    }

    if (out['is_positive'] == null) {
      final key = out['disease_key']?.toString().toLowerCase() ?? '';
      final dt = out['disease_type']?.toString().toLowerCase() ?? '';
      final dis = out['disease']?.toString().toLowerCase() ?? '';
      out['is_positive'] = !(key.contains('healthy') ||
          dt == 'healthy' ||
          dis.contains('healthy'));
    }

    return out;
  }

  Future<AnalyzeSaveResult> save(Map<String, dynamic> payload) async {
    final url = kAnalyzeSaveApiUrl.trim();
    assertValidAnalyzeSaveUrl(url);
    final logHost = analyzeSaveUrlHostForLog(url);
    _logAnalyzeSave('POST target host=${logHost ?? "?"} (https API)');

    final swShape = Stopwatch()..start();
    final body = ensureApiShape(payload);
    swShape.stop();
    _logAnalyzeSave('ensureApiShape: ${swShape.elapsedMilliseconds}ms');

    final swHttp = Stopwatch()..start();
    late final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.post<Map<String, dynamic>>(
        url,
        data: body,
        options: Options(
          headers: const {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ),
      );
      swHttp.stop();
      final host = Uri.tryParse(url)?.host ?? '?';
      _logAnalyzeSave(
        'POST ok: ${swHttp.elapsedMilliseconds}ms '
        'status=${response.statusCode} host=$host',
      );
    } catch (e, st) {
      swHttp.stop();
      _logAnalyzeSave(
        'POST fail: ${swHttp.elapsedMilliseconds}ms error=$e',
      );
      logErrorToTerminal('AnalyzeSave', e, st);
      rethrow;
    }

    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Empty response body',
      );
    }
    if (data['error'] != null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: data['error'].toString(),
        response: response,
      );
    }
    return AnalyzeSaveResult(
      success: data['success'] == true,
      scanId: data['scanId'],
      message: data['message']?.toString(),
    );
  }
}

class AnalyzeSaveResult {
  const AnalyzeSaveResult({
    required this.success,
    this.scanId,
    this.message,
  });

  final bool success;
  final Object? scanId;
  final String? message;
}
