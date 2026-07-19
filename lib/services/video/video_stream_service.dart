import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/logger_service.dart';

/// Real MJPEG video stream service.
///
/// Connects to [AppConfig.videoStreamUrl] (multipart/x-mixed-replace) and
/// parses the byte stream into individual JPEG frames delivered via [frames].
///
/// Automatically reconnects on any connection failure using the delay defined
/// in [AppConfig.videoReconnectDelay].
class VideoStreamService extends ChangeNotifier {
  VideoStreamService._();
  static final VideoStreamService instance = VideoStreamService._();

  final StreamController<Uint8List> _frameController =
      StreamController<Uint8List>.broadcast();

  bool _streaming = false;
  bool _disposed = false;
  String _streamUrl = AppConfig.videoStreamUrl;
  Timer? _reconnectTimer;
  HttpClient? _httpClient;

  // ── Public API ─────────────────────────────────────────────────────────────

  Stream<Uint8List> get frames => _frameController.stream;
  bool get isStreaming => _streaming;
  String get streamUrl => _streamUrl;

  /// Override the default stream URL before calling [start].
  void configure(String url) {
    _streamUrl = url;
    notifyListeners();
  }

  Future<void> start() async {
    if (_streaming) return;
    _streaming = true;
    _disposed = false;
    notifyListeners();
    _connectMjpeg();
  }

  Future<void> stop() async {
    _disposed = true;
    _streaming = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _closeHttpClient();
    notifyListeners();
  }

  /// Inject a pre-decoded frame (used by tests / future RTSP adapter).
  void addFrame(Uint8List frame) {
    if (!_frameController.isClosed) {
      _frameController.add(frame);
    }
  }

  // ── MJPEG streaming ────────────────────────────────────────────────────────

  Future<void> _connectMjpeg() async {
    if (_disposed) return;
    try {
      _httpClient = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10)
        ..idleTimeout = const Duration(seconds: 60);

      final request = await _httpClient!.getUrl(Uri.parse(_streamUrl));
      request.headers.set('Accept', 'multipart/x-mixed-replace, image/jpeg');
      final response = await request.close();

      if (response.statusCode != 200) {
        LoggerService.instance.error(
            'MJPEG HTTP ${response.statusCode} from $_streamUrl');
        _scheduleReconnect();
        return;
      }

      LoggerService.instance.video('MJPEG stream connected: $_streamUrl');
      await _parseMjpeg(response);
    } catch (e) {
      if (!_disposed) {
        LoggerService.instance.error('MJPEG connect failed: $e');
        _scheduleReconnect();
      }
    }
  }

  Future<void> _parseMjpeg(Stream<List<int>> source) async {
    // JPEG frames are delimited by SOI (0xFF 0xD8) and EOI (0xFF 0xD9)
    // markers, regardless of multipart boundary.
    final buffer = <int>[];
    const soi = [0xFF, 0xD8];
    const eoi = [0xFF, 0xD9];

    try {
      await for (final chunk in source) {
        if (_disposed) return;
        buffer.addAll(chunk);

        int searchFrom = 0;
        while (true) {
          final soiIdx = _indexOf(buffer, soi, searchFrom);
          if (soiIdx == -1) break;

          final eoiIdx = _indexOf(buffer, eoi, soiIdx + 2);
          if (eoiIdx == -1) break;

          final frameEnd = eoiIdx + 2;
          final frame = Uint8List.fromList(buffer.sublist(soiIdx, frameEnd));
          if (!_frameController.isClosed) {
            _frameController.add(frame);
          }
          searchFrom = frameEnd;
        }

        // Discard already-processed bytes.
        if (searchFrom > 0) buffer.removeRange(0, searchFrom);

        // Safety valve: prevent unbounded memory growth on a bad stream.
        if (buffer.length > 5 * 1024 * 1024) {
          LoggerService.instance.warning('MJPEG buffer overflow – clearing');
          buffer.clear();
        }
      }
    } catch (e) {
      if (!_disposed) {
        LoggerService.instance.error('MJPEG stream error: $e');
      }
    }

    if (!_disposed) {
      LoggerService.instance.warning('MJPEG stream ended – scheduling reconnect');
      _scheduleReconnect();
    }
  }

  int _indexOf(List<int> data, List<int> pattern, int from) {
    outer:
    for (int i = from; i <= data.length - pattern.length; i++) {
      for (int j = 0; j < pattern.length; j++) {
        if (data[i + j] != pattern[j]) continue outer;
      }
      return i;
    }
    return -1;
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _closeHttpClient();
    _reconnectTimer?.cancel();
    _reconnectTimer =
        Timer(AppConfig.videoReconnectDelay, _connectMjpeg);
  }

  void _closeHttpClient() {
    try {
      _httpClient?.close(force: true);
    } catch (_) {}
    _httpClient = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _closeHttpClient();
    _frameController.close();
    super.dispose();
  }
}
