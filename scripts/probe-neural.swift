import Foundation
import AVFoundation
@main struct VoiceProbe {
    static func main() async {
        do {
            let text = "按下开关，灯亮了。可你有没有想过，让它发亮的能量，究竟怎样来到插座？先拆开一个常见误会：一度电不是一包电子，而是一份能量。一个一千瓦的电器，持续工作一小时，就消耗一千瓦时，也就是一度电。从电厂到家中，这份能量要经过发电、升压、输电、降压，最后才走进我们熟悉的插座。"
            let result = try await NeuralVoice.synthesize(text, token: edgeSecurityToken())
            let path = URL(fileURLWithPath: "output/voice-preview-xiaoxiao.mp3")
            try result.audio.write(to: path, options: .atomic)
            let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(result.boundaries).write(to: URL(fileURLWithPath: "output/voice-preview-xiaoxiao.boundaries.json"))
            let asset = AVURLAsset(url: path)
            let duration = try await asset.load(.duration)
            print("VOICE_SUCCESS \(NeuralVoice.identifier) duration=\(CMTimeGetSeconds(duration)) bytes=\(result.audio.count) boundaries=\(result.boundaries.count)")
        } catch { fputs("VOICE_FAILED \(error)\n", stderr); exit(1) }
    }
}
