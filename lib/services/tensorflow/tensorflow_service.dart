

import 'package:flutter/foundation.dart';

class TensorflowService extends ChangeNotifier {
  TensorflowService._();

  static final TensorflowService instance = TensorflowService._();

  bool _initialized = false;
  bool _modelLoaded = false;
  String _modelPath = "";

  bool get isInitialized => _initialized;
  bool get isModelLoaded => _modelLoaded;
  String get modelPath => _modelPath;

  Future<void> initialize() async {
    _initialized = true;
    notifyListeners();
  }

  Future<void> loadModel(String path) async {
    _modelPath = path;
    _modelLoaded = true;
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> detect(Uint8List imageBytes) async {
    if (!_modelLoaded) return [];
    // TFLite inference will be integrated here.
    return <Map<String, dynamic>>[];
  }

  Future<void> unloadModel() async {
    _modelLoaded = false;
    _modelPath = "";
    notifyListeners();
  }
}

