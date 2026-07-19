/// Centralised application configuration.
///
/// All network endpoints are defined here. Never hard-code URLs elsewhere.
class AppConfig {
  AppConfig._();

  // ---------------------------------------------------------------------------
  // Raspberry Pi backend
  // ---------------------------------------------------------------------------

  static const String _host = '100.80.94.32';
  static const int _port = 8000;

  /// WebSocket telemetry endpoint (10 Hz real-time stream).
  static const String wsUrl =
      'ws://$_host:$_port/ws/telemetry';

  /// REST telemetry snapshot endpoint.
  static const String restTelemetryUrl =
      'http://$_host:$_port/api/v1/telemetry';

  /// MJPEG video stream endpoint.
  static const String videoStreamUrl =
      'http://$_host:$_port/video/stream';

  // ---------------------------------------------------------------------------
  // Reconnection policy
  // ---------------------------------------------------------------------------

  /// Initial delay before the first WebSocket reconnect attempt.
  static const Duration wsReconnectDelay = Duration(seconds: 3);

  /// Maximum back-off delay between WebSocket reconnect attempts.
  static const Duration wsReconnectDelayMax = Duration(seconds: 30);

  /// Delay before retrying a failed MJPEG connection.
  static const Duration videoReconnectDelay = Duration(seconds: 5);

  /// WebSocket connect timeout.
  static const Duration wsConnectTimeout = Duration(seconds: 10);
}
