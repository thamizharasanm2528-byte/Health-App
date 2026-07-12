import 'package:flutter/foundation.dart';

/// Lightweight logging utility for diagnostics and crash/telemetry checks.
class AppLogger {
  /// Logs an error with specific context and stack trace.
  static void error(String context, Object error, [StackTrace? stackTrace]) {
    debugPrint('🚨 [AppLogger] Error in $context: $error');
    if (stackTrace != null && kDebugMode) {
      debugPrint(stackTrace.toString());
    }
  }

  /// Logs informational trace messages.
  static void info(String message) {
    debugPrint('ℹ️ [AppLogger] $message');
  }
}
