package com.example.audio_to_mp3_converter

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer


class AudioConverter(flutterEngine: FlutterEngine) {
    private val channel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        "audio_converter"
    )

    init {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "convertToMp3" -> {
                    val inputPath = call.argument<String>("inputPath")!!
                    val outputPath = call.argument<String>("outputPath")!!
                    val bitrate = call.argument<Int>("bitrate") ?: 192
                    val sampleRate = call.argument<Int>("sampleRate") ?: 44100
                    
                    try {
                        convertToMp3(inputPath, outputPath, bitrate, sampleRate)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CONVERSION_FAILED", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    @SuppressLint("WrongConstant", "NewApi")
    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    private fun convertToMp3(
        inputPath: String,
        outputPath: String,
        bitrate: Int,
        sampleRate: Int
    ) {
        val extractor = MediaExtractor()
        extractor.setDataSource(inputPath)

        val muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)

        val trackIndex = selectAudioTrack(extractor)
        if (trackIndex < 0) {
            throw Exception("No audio track found")
        }

        val format = extractor.getTrackFormat(trackIndex)
        format.setInteger(MediaFormat.KEY_BIT_RATE, bitrate * 1000)
        format.setInteger(MediaFormat.KEY_SAMPLE_RATE, sampleRate)

        val muxerTrackIndex = muxer.addTrack(format)
        extractor.selectTrack(trackIndex)

        muxer.start()
        val buffer = ByteBuffer.allocate(1024 * 1024)
        val bufferInfo = MediaCodec.BufferInfo()

        while (true) {
            val sampleSize = extractor.readSampleData(buffer, 0)
            if (sampleSize < 0) break

            bufferInfo.presentationTimeUs = extractor.sampleTime
            bufferInfo.flags = extractor.sampleFlags
            bufferInfo.size = sampleSize

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR2) {
                muxer.writeSampleData(muxerTrackIndex, buffer, bufferInfo)
            }
            extractor.advance()
        }

        muxer.stop()
        muxer.release()
        extractor.release()
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN)
    private fun selectAudioTrack(extractor: MediaExtractor): Int {
        for (i in 0 until extractor.trackCount) {
            val format = extractor.getTrackFormat(i)
            val mime = format.getString(MediaFormat.KEY_MIME)
            if (mime?.startsWith("audio/") == true) {
                return i
            }
        }
        return -1
    }
}