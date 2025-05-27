import 'dart:developer';
import 'package:flutter/material.dart';

/// Service for centralized error logging and user notification.
class ErrorService {
  /// Logs error with optional context and stack trace.
  static void logError(Object error, StackTrace stack, {String? context}) {
    final ctx = context != null ? '[$context] ' : '';
    // Use log from dart:developer for structured logging
    log('$ctx${error.runtimeType}: $error', stackTrace: stack);
  }

  /// Shows a dialog with error details to the user.
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
