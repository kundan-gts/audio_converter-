import 'dart:io';

import 'package:audio_to_mp3_converter/audio_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  Future<String> copyAssetToTemp(String assetPath, String filename) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path; // ✅ pass this path to native method
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _convertedPath;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                String inputPath = await copyAssetToTemp('asset/audio.m4a', 'audio.m4a');
                final result = await AudioConverter.convertToMp3(
                  inputPath: inputPath,
                  bitrate: 192,
                );

                if (result.success) {
                  _convertedPath = result.outputPath;
                  print('Conversion successful: $_convertedPath');
                  await _audioPlayer.setFilePath(_convertedPath!);
                  _audioPlayer.play();
                } else {
                  print('Failed: ${result.errorMessage}');
                }
              } catch (e) {
                print('Error: $e');
              }
            },
            child: const Text('Convert to MP3'),
          ),
        ),
      ),
    );
  }
}
