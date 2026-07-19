import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/logger_service.dart';
import '../../models/drone_model.dart';

enum WsStatus { disconnected, connecting, connected }

/// WebSocket client that connects to the Raspberry Pi backend at
/// [AppConfig.wsUrl] and broadcasts [DroneModel] instances parsed from
/// the incoming [TelemetrySnapshot] JSON frames.
///
/// Reconnects automatically with exponential back-off on any failure.
class WebSocketService extends ChangeNotifier {
  WebSocketService._();
  static final WebSocketService instance = WebSocketService._();

  WebSocket? _socket;
  WsStatus _status = WsStatus.disconnected;
  bool _running = false;
  int _retryCount = 0;
  Timer? _reconnectTimer;

  final StreamController<DroneModel> _streamController =
      StreamController<DroneModel>.broadcast();

  // ── Public API ─────────────────────────────────────────────────────────────

  WsStatus get status => _status;
  bool get isConnected => _status == WsStatus.connected;
  Stream<DroneModel> get stream => _streamController.stream;

  /// Start the WebSocket and keep it alive with automatic reconnection.
  void start() {
    if (_running) return;
    _running = true;
    _connect();
  }

  /// Permanently stop the WebSocket (no further reconnect attempts).
  void stop() {
    _running = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _closeSocket();
    _setStatus(WsStatus.disconnected);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _connect() async {
    if (!_running) return;

    _setStatus(WsStatus.connecting);
    LoggerService.instance
        .info('WebSocket connecting to ${AppConfig.wsUrl}');

    try {
      _socket = await WebSocket.connect(AppConfig.wsUrl)
          .timeout(AppConfig.wsConnectTimeout);

      _retryCount = 0;
      _setStatus(WsStatus.connected);
      LoggerService.instance.info('WebSocket connected');

      _socket!.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } on TimeoutException {
      LoggerService.instance.warning('WebSocket connect timeout');
      _setStatus(WsStatus.disconnected);
      _scheduleReconnect();
    } catch (e, st) {
      LoggerService.instance.error('WebSocket connect error', e, st);
      _setStatus(WsStatus.disconnected);
      _scheduleReconnect();
    }
  }

  void _onData(dynamic data) {
    if (data is! String) return;
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      // Skip keepalive ping frames sent by the server every 30 s.
      if (json['type'] == 'ping') return;
      final model = DroneModel.fromJson(json);
      if (!_streamController.isClosed) {
        _streamController.add(model);
      }
    } catch (e) {
      LoggerService.instance.error('WebSocket parse error: $e');
    }
  }

  void _onError(Object error) {
    LoggerService.instance.error('WebSocket stream error: $error');
    _setStatus(WsStatus.disconnected);
    _scheduleReconnect();
  }

  void _onDone() {
    LoggerService.instance.warning('WebSocket connection closed');
    _setStatus(WsStatus.disconnected);
    _scheduleReconnect();
  }

  void _closeSocket() {
    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;
  }

  /// Exponential back-off: 3 s, 6 s, 12 s, … up to [AppConfig.wsReconnectDelayMax].
  void _scheduleReconnect() {
    if (!_running) return;
    _reconnectTimer?.cancel();
    final base = AppConfig.wsReconnectDelay.inSeconds;
    final cap = AppConfig.wsReconnectDelayMax.inSeconds;
    final seconds = min(base * pow(2, _retryCount).toInt(), cap);
    _retryCount++;
    LoggerService.instance
        .info('WebSocket retry #$_retryCount in ${seconds}s');
    _reconnectTimer = Timer(Duration(seconds: seconds), _connect);
  }

  void _setStatus(WsStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    _streamController.close();
    super.dispose();
  }
}
