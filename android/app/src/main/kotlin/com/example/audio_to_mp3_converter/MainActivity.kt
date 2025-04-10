package com.example.audio_to_mp3_converter
import com.example.audio_to_mp3_converter.AudioConverter // 👈 Add this

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 👇 This line registers your plugin/channel handler
        AudioConverter(flutterEngine)
    }
}
