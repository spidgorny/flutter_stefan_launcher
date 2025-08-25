import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ErrorLoggerService {
  static final ErrorLoggerService _instance = ErrorLoggerService._internal();

  factory ErrorLoggerService() {
    return _instance;
  }

  ErrorLoggerService._internal();

  Future<void> logError(
    dynamic error,
    StackTrace stackTrace, {
    String? context,
  }) async {
    // Print error in debug mode
    if (kDebugMode) {
      print('ERROR: $context');
      print('ERROR DETAILS: $error');
      print('STACKTRACE: $stackTrace');
    }

    try {
      // Determine error type for better handling
      String errorType = _getErrorType(error);

      // Prepare error data for logging or sending to a backend service
      Map<String, dynamic> errorData = {
        'timestamp': DateTime.now().toIso8601String(),
        'errorType': errorType,
        'errorMessage': error.toString(),
        'stackTrace': stackTrace.toString(),
        'context': context ?? 'unknown',
        'platform': Platform.operatingSystem,
        'platformVersion': Platform.operatingSystemVersion,
      };

      // Here you can implement sending logs to a backend service
      // or save them locally for future synchronization

      // Example: await _sendErrorToBackend(errorData);
    } catch (e) {
      // Fallback error handling to avoid infinite loops
      if (kDebugMode) {
        print('Failed to log error: $e');
      }
    }
  }

  String _getErrorType(dynamic error) {
    if (error is DioException) {
      return 'NetworkError';
    } else if (error is FormatException) {
      return 'FormatError';
    } else if (error is TimeoutException) {
      return 'TimeoutError';
    } else if (error is FileSystemException) {
      return 'FileSystemError';
    } else if (error.toString().contains('SoundPool') ||
        error.toString().contains('audio') ||
        error.toString().contains('sound')) {
      return 'AudioError';
    } else {
      return 'GenericError';
    }
  }

  Future<void> _sendErrorToBackend(Map<String, dynamic> errorData) async {
    // Implement your backend reporting logic here
    // Use a different Dio instance to avoid recursive errors
    try {
      final Dio dio = Dio();
      await dio.post(
        'YOUR_ERROR_REPORTING_ENDPOINT',
        data: errorData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } catch (e) {
      // Silent catch to prevent loops
      if (kDebugMode) {
        print('Failed to send error to backend: $e');
      }
    }
  }

  // Specific method to handle media codec errors seen in the logs
  Future<void> handleMediaCodecError(String errorDetails) async {
    if (kDebugMode) {
      print(
        'Handling MediaCodec error: ${errorDetails.substring(0, min(100, errorDetails.length))}...',
      );
    }

    // Extract important information from the codec error
    RegExp codecRegex = RegExp(r'\[(.*?)\]');
    String codec =
        codecRegex.firstMatch(errorDetails)?.group(1) ?? 'unknown_codec';

    Map<String, dynamic> errorData = {
      'timestamp': DateTime.now().toIso8601String(),
      'errorType': 'MediaCodecError',
      'codec': codec,
      'details': errorDetails,
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
    };

    await logError(
      'MediaCodec error: $codec',
      StackTrace.current,
      context: 'Audio playback',
    );
  }
}
