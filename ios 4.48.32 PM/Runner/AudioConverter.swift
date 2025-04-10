import AVFoundation


public class AudioConverter {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "audio_converter",
            binaryMessenger: registrar.messenger()
        )
        
        let instance = AudioConverter()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
}

extension AudioConverter: FlutterPlugin {
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "convertToMp3":
            guard let args = call.arguments as? [String: Any],
                  let inputPath = args["inputPath"] as? String,
                  let outputPath = args["outputPath"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
                return
            }
            
            let bitrate = args["bitrate"] as? Int ?? 192
            let sampleRate = args["sampleRate"] as? Int ?? 44100
            
            convertToMp3(
                inputPath: inputPath,
                outputPath: outputPath,
                bitrate: bitrate,
                sampleRate: sampleRate,
                result: result
            )
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func convertToMp3(
        inputPath: String,
        outputPath: String,
        bitrate: Int,
        sampleRate: Int,
        result: @escaping FlutterResult
    ) {
        let inputUrl = URL(fileURLWithPath: inputPath)
        let outputUrl = URL(fileURLWithPath: outputPath)
        
        let asset = AVAsset(url: inputUrl)
        guard let track = asset.tracks(withMediaType: .audio).first else {
            result(FlutterError(code: "NO_AUDIO_TRACK", message: nil, details: nil))
            return
        }
        
        let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetPassthrough
        )!
        
        exportSession.outputURL = outputUrl
        exportSession.outputFileType = .mp3
        
        // Configure audio settings
        let audioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEGLayer3,
            AVEncoderBitRateKey: bitrate * 1000,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        exportSession.audioTimePitchAlgorithm = .varispeed
        exportSession.shouldOptimizeForNetworkUse = true
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                result(true)
            case .failed:
                result(FlutterError(
                    code: "CONVERSION_FAILED",
                    message: exportSession.error?.localizedDescription,
                    details: nil
                ))
            case .cancelled:
                result(FlutterError(
                    code: "CONVERSION_CANCELLED",
                    message: nil,
                    details: nil
                ))
            default:
                result(FlutterError(
                    code: "UNKNOWN_ERROR",
                    message: nil,
                    details: nil
                ))
            }
        }
    }
}