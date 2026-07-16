import 'dart:developer' as developer;

class LoggerService {
  LoggerService._();
  static final LoggerService instance = LoggerService._();

  void info(String message) {
    developer.log(message, name: 'VARUNA-INFO');
  }

  void warning(String message) {
    developer.log(message, name: 'VARUNA-WARNING');
  }

  void error(String message,[Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: 'VARUNA-ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void mission(String message) => info('[MISSION] $message');
  void telemetry(String message) => info('[TELEMETRY] $message');
  void ai(String message) => info('[AI] $message');
  void video(String message) => info('[VIDEO] $message');
}

 