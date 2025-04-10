import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AudioConversionResult {
  final String outputPath;
  final bool success;
  final String? errorMessage;

  AudioConversionResult({
    required this.outputPath,
    required this.success,
    this.errorMessage,
  });
}

class AudioConverter {
  static const MethodChannel _channel = MethodChannel('audio_converter');

  /// Converts any audio file to MP3 format
  static Future<AudioConversionResult> convertToMp3({
    required String inputPath,
    String? outputPath,
    int bitrate = 192,
    int sampleRate = 44100,
  }) async {
    try {
      // Set default output path if not provided
      final outputFilePath = outputPath ?? await _generateOutputPath();
      final result = await _channel.invokeMethod('convertToMp3', {
        'inputPath': inputPath,
        'outputPath': outputFilePath,
        'bitrate': bitrate,
        'sampleRate': sampleRate,
      });

      return AudioConversionResult(
        outputPath: outputFilePath,
        success: result == true,
      );
    } on PlatformException catch (e) {
      return AudioConversionResult(
        outputPath: outputPath ?? '',
        success: false,
        errorMessage: e.message,
      );
    }
  }

  static Future<String> _generateOutputPath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.mp3';
  }
}