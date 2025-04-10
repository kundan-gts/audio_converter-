import 'package:flutter/services.dart';

class NativeAudioConverter {
  static const MethodChannel _channel = MethodChannel('audio_converter');

  static Future<bool> convertToMp3({
    required String inputPath,
    required String outputPath,
    int bitrate = 192,
    int sampleRate = 44100,
  }) async {
    try {
      final result = await _channel.invokeMethod('convertToMp3', {
        'inputPath': inputPath,
        'outputPath': outputPath,
        'bitrate': bitrate,
        'sampleRate': sampleRate,
      });
      return result == true;
    } on PlatformException {
      return false;
    }
  }
}