import 'dart:async';

import 'package:flutter/services.dart';

import '../services/error_logger_service.dart';

class AudioUtils {
  static final ErrorLoggerService _errorLogger = ErrorLoggerService();

  /// Safely load sound with error handling
  static Future<int?> loadSound(dynamic soundPool, String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      return await soundPool.load(data);
    } catch (e, stackTrace) {
      _errorLogger.logError(
        e,
        stackTrace,
        context: 'Failed to load sound: $assetPath',
      );
      return null;
    }
  }

  /// Safely play sound with error handling
  static Future<int?> playSound(
    dynamic soundPool,
    int soundId, {
    double volume = 1.0,
  }) async {
    try {
      return await soundPool.play(soundId, volume: volume);
    } catch (e, stackTrace) {
      _errorLogger.logError(
        e,
        stackTrace,
        context: 'Failed to play sound ID: $soundId',
      );
      return null;
    }
  }

  /// Check if audio can be played on the device
  static Future<bool> isAudioSupported() async {
    try {
      // This is a simple check that could be expanded based on your needs
      await rootBundle.load('assets/test_audio.wav');
      return true;
    } catch (e, stackTrace) {
      _errorLogger.logError(
        e,
        stackTrace,
        context: 'Audio support check failed',
      );
      return false;
    }
  }

  /// Handle audio player disposal safely
  static Future<void> disposeAudioPlayer(dynamic player) async {
    try {
      await player.dispose();
    } catch (e, stackTrace) {
      _errorLogger.logError(
        e,
        stackTrace,
        context: 'Failed to dispose audio player',
      );
    }
  }
}
