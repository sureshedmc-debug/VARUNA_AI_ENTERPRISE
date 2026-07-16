import 'dart:async';


import 'package:flutter/foundation.dart';

class VideoStreamService extends ChangeNotifier {
  VideoStreamService._();

  static final VideoStreamService instance =
      VideoStreamService._();

  final StreamController<Uint8List> _frameController =
      StreamController<Uint8List>.broadcast();

  bool _streaming = false;

  String _streamUrl = '';

  Stream<Uint8List> get frames =>
      _frameController.stream;

  bool get isStreaming => _streaming;

  String get streamUrl => _streamUrl;

  Future<void> initialize() async {}

  void configure(String url) {
    _streamUrl = url;
    notifyListeners();
  }

  Future<void> start() async {
    _streaming = true;
    notifyListeners();
  }

  Future<void> stop() async {
    _streaming = false;
    notifyListeners();
  }

  void addFrame(Uint8List frame) {
    if (!_frameController.isClosed) {
      _frameController.add(frame);
    }
  }

  @override
  void dispose() {
    _frameController.close();
    super.dispose();
  }
}