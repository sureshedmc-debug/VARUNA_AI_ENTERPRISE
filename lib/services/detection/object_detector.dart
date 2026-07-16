import 'dart:typed_data';

import '../tensorflow/tensorflow_service.dart';

class DetectionResult {
  final String label;
  final double confidence;
  final double left;
  final double top;
  final double width;
  final double height;

  DetectionResult({
    required this.label,
    required this.confidence,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  factory DetectionResult.fromMap(Map<String, dynamic> map) {
    return DetectionResult(
      label: map['label'] ?? '',
      confidence: (map['confidence'] ?? 0).toDouble(),
      left: (map['left'] ?? 0).toDouble(),
      top: (map['top'] ?? 0).toDouble(),
      width: (map['width'] ?? 0).toDouble(),
      height: (map['height'] ?? 0).toDouble(),
    );
  }
}

class ObjectDetector {
  ObjectDetector._();

  static final ObjectDetector instance = ObjectDetector._();

  Future<List<DetectionResult>> detect(Uint8List imageBytes) async {
    final rawResults =
        await TensorflowService.instance.detect(imageBytes);

    return rawResults
        .map((e) => DetectionResult.fromMap(e))
        .toList();
  }
}

