

import 'package:flutter/foundation.dart';

import '../services/ai/ai_copilot_service.dart';
import '../services/detection/object_detector.dart';
import '../services/tensorflow/tensorflow_service.dart';

class AIController extends ChangeNotifier {
  AIController._();

  static final AIController instance = AIController._();

  final AICopilotService ai = AICopilotService.instance;

  List<DetectionResult> _detections = [];

  List<DetectionResult> get detections => List.unmodifiable(_detections);

  Future<void> refreshAdvice() async {
    ai.evaluate();
    notifyListeners();
  }

  Future<void> detectFrame(Uint8List frame) async {
    _detections = await ObjectDetector.instance.detect(frame);
    notifyListeners();
  }

  bool get modelLoaded => TensorflowService.instance.isModelLoaded;
}

 