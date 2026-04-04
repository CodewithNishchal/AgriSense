import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Loads `plant_disease_model_int8.tflite` once and runs leaf image classification.
class TFLiteHelper {
  TFLiteHelper._();
  static final TFLiteHelper instance = TFLiteHelper._();

  static const String _assetPath = 'assets/models/plant_disease_model_int8.tflite';

  Interpreter? _interpreter;
  Future<void>? _loadFuture;

  /// Set when the model fails to load from assets (path must be under `frontend/`).
  String? loadError;

  /// Set when inference fails after a successful load (image decode, shape, run, …).
  String? lastAnalyzeError;

  Future<void> ensureInitialized() {
    _loadFuture ??= _loadModel();
    return _loadFuture!;
  }

  Future<void> _loadModel() async {
    loadError = null;
    try {
      await rootBundle.load(_assetPath);
    } catch (e, st) {
      loadError =
          'Model asset not in app bundle: $_assetPath\n\n'
          'File must live at assets/models/ next to pubspec.yaml, and pubspec must list '
          'that folder (e.g. `- assets/models/`) — listing only `- assets/` does NOT include subfolders.\n\n'
          'Then: flutter clean && flutter pub get && full rebuild.\n\n'
          '($e)';
      // ignore: avoid_print
      print('TFLite asset missing: $e\n$st');
      _interpreter = null;
      return;
    }
    try {
      _interpreter = await Interpreter.fromAsset(_assetPath);
      final inT = _interpreter!.getInputTensor(0);
      final outT = _interpreter!.getOutputTensor(0);
      // ignore: avoid_print
      print(
        'TFLite loaded: input shape=${inT.shape} type=${inT.type} '
        'output shape=${outT.shape} type=${outT.type}',
      );
    } catch (e, st) {
      loadError = 'Failed to open TFLite model: $e';
      // ignore: avoid_print
      print('TFLite load failed: $e\n$st');
      _interpreter = null;
    }
  }

  static int _spatialDim(int d, {int fallback = 256}) => d > 0 ? d : fallback;

  /// Matches NumPy: `np.uint8(pixel).astype(np.int8)` on 0–255 RGB (values ≥128 go negative).
  static int _asInt8LikeNumpy(int u) {
    final v = u.clamp(0, 255);
    return v >= 128 ? v - 256 : v;
  }

  /// Best message for UI when [analyzeImage] returned null.
  String describeFailure() {
    if (loadError != null && loadError!.isNotEmpty) return loadError!;
    if (lastAnalyzeError != null && lastAnalyzeError!.isNotEmpty) {
      return lastAnalyzeError!;
    }
    return 'Offline model did not return a result.';
  }

  /// Full output vector + tensor shapes (for debug UI).
  Future<Map<String, dynamic>?> analyzeImageDebug(File imageFile) async {
    final flat = await _runInferenceToFlatOutput(imageFile);
    if (flat == null) return null;
    final best = _argmax(flat.vector);
    return {
      'index': best['index'],
      'confidence': best['confidence'],
      'raw_output': List<double>.from(flat.vector),
      'input_shape': flat.inputShape,
      'output_shape': flat.outputShape,
    };
  }

  /// Returns `{index, confidence}` for the winning class, or null on failure.
  Future<Map<String, dynamic>?> analyzeImage(File imageFile) async {
    final flat = await _runInferenceToFlatOutput(imageFile);
    if (flat == null) return null;
    return _argmax(flat.vector);
  }

  Future<
      ({
        List<double> vector,
        List<int> inputShape,
        List<int> outputShape,
      })?> _runInferenceToFlatOutput(File imageFile) async {
    lastAnalyzeError = null;
    await ensureInitialized();
    final interpreter = _interpreter;
    if (interpreter == null) {
      lastAnalyzeError = loadError ?? 'Model not loaded.';
      return null;
    }

    final raw = await imageFile.readAsBytes();
    final decoded = img.decodeImage(raw);
    if (decoded == null) {
      lastAnalyzeError =
          'Could not decode the image. Use camera or a JPG/PNG file (HEIC often fails).';
      return null;
    }

    final inTensor = interpreter.getInputTensor(0);
    final outTensor = interpreter.getOutputTensor(0);
    final shape = List<int>.from(inTensor.shape);
    final outShape = List<int>.from(outTensor.shape);
    if (shape.length != 4 || shape[0] != 1) {
      lastAnalyzeError =
          'Unexpected model input rank/shape: $shape (expected 4D NCHW or NHWC).';
      return null;
    }

    final type = inTensor.type;
    dynamic input;

    if (shape.length >= 4 && shape[3] == 3) {
      final h = _spatialDim(shape[1]);
      final w = _spatialDim(shape[2]);
      input = _buildNhwcInput(decoded, h, w, type);
    } else if (shape.length >= 4 && shape[1] == 3) {
      final h = _spatialDim(shape[2]);
      final w = _spatialDim(shape[3]);
      input = _buildNchwInput(decoded, h, w, type);
    } else {
      lastAnalyzeError =
          'Unsupported input layout shape=$shape (need …,3,…,… or …,…,…,3).';
      return null;
    }

    final output = _allocateOutput(outShape);
    try {
      interpreter.run(input, output);
    } catch (e, st) {
      lastAnalyzeError = 'Inference failed: $e';
      // ignore: avoid_print
      print('TFLite run failed: $e\n$st');
      return null;
    }

    final probs = _flattenToDoubles(output);
    if (probs.isEmpty) {
      lastAnalyzeError =
          'Model produced no output values (check output tensor shape).';
      return null;
    }
    return (vector: probs, inputShape: shape, outputShape: outShape);
  }

  List<List<List<List<num>>>> _buildNhwcInput(
    img.Image decoded,
    int h,
    int w,
    TensorType type,
  ) {
    final resized = img.copyResize(decoded, width: w, height: h);
    return [
      List.generate(
        h,
        (y) => List.generate(
          w,
          (x) {
            final p = resized.getPixel(x, y);
            final r = p.r.toDouble();
            final g = p.g.toDouble();
            final b = p.b.toDouble();
            // Same branches as your Colab: float32 / int8 / uint8
            if (type == TensorType.float32) {
              return [r / 255.0, g / 255.0, b / 255.0];
            }
            if (type == TensorType.int8) {
              return [
                _asInt8LikeNumpy(r.round()),
                _asInt8LikeNumpy(g.round()),
                _asInt8LikeNumpy(b.round()),
              ];
            }
            if (type == TensorType.uint8) {
              return [
                r.round().clamp(0, 255),
                g.round().clamp(0, 255),
                b.round().clamp(0, 255),
              ];
            }
            return [r / 255.0, g / 255.0, b / 255.0];
          },
        ),
      ),
    ];
  }

  List<List<List<List<num>>>> _buildNchwInput(
    img.Image decoded,
    int h,
    int w,
    TensorType type,
  ) {
    final resized = img.copyResize(decoded, width: w, height: h);
    final planeR = List.generate(h, (_) => List<num>.filled(w, 0));
    final planeG = List.generate(h, (_) => List<num>.filled(w, 0));
    final planeB = List.generate(h, (_) => List<num>.filled(w, 0));
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = resized.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        if (type == TensorType.float32) {
          planeR[y][x] = r / 255.0;
          planeG[y][x] = g / 255.0;
          planeB[y][x] = b / 255.0;
        } else if (type == TensorType.int8) {
          planeR[y][x] = _asInt8LikeNumpy(r.round());
          planeG[y][x] = _asInt8LikeNumpy(g.round());
          planeB[y][x] = _asInt8LikeNumpy(b.round());
        } else if (type == TensorType.uint8) {
          planeR[y][x] = r.round().clamp(0, 255);
          planeG[y][x] = g.round().clamp(0, 255);
          planeB[y][x] = b.round().clamp(0, 255);
        } else {
          planeR[y][x] = r / 255.0;
          planeG[y][x] = g / 255.0;
          planeB[y][x] = b / 255.0;
        }
      }
    }
    return [
      [planeR, planeG, planeB],
    ];
  }

  dynamic _allocateOutput(List<int> outShape) {
    if (outShape.isEmpty) return <double>[];
    if (outShape.length == 1) {
      return List<double>.filled(outShape[0], 0);
    }
    if (outShape.length == 2 && outShape[0] == 1) {
      return [List<double>.filled(outShape[1], 0)];
    }
    final total = outShape.fold<int>(1, (a, b) => a * b);
    return List<double>.filled(total, 0);
  }

  List<double> _flattenToDoubles(dynamic output) {
    if (output is List<double>) return output;
    if (output is! List || output.isEmpty) return [];
    final first = output.first;
    if (first is num) {
      return output.map((e) => (e as num).toDouble()).toList();
    }
    if (first is List) {
      return _flattenToDoubles(first);
    }
    return [];
  }

  Map<String, dynamic> _argmax(List<double> probabilities) {
    var winningIndex = 0;
    var highest = probabilities[0];
    for (var i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > highest) {
        highest = probabilities[i];
        winningIndex = i;
      }
    }
    return {'index': winningIndex, 'confidence': highest};
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _loadFuture = null;
  }
}
