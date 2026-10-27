import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Debug-only diagnostics. Never pass tokens, emails or habit content.
abstract final class AppLogger {
  static void error(
    String message, {
    required String name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}
