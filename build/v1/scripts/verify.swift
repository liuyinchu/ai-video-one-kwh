import Foundation
import AVFoundation
import ImageIO
import UniformTypeIdentifiers
import CoreMedia
import AudioToolbox

let fm = FileManager.default
let path = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "output/一度电如何来到插座.mp4"
let asset = AVURLAsset(url: URL(fileURLWithPath: path))
let duration = CMTimeGetSeconds(asset.duration)
let videoTracks = asset.tracks(withMediaType: .video)
let audioTracks = asset.tracks(withMediaType: .audio)
guard let video = videoTracks.first, let audio = audioTracks.first else {
    fatalError("成片必须同时包含视频轨道和音频轨道")
}
let timelineData = try Data(contentsOf: URL(fileURLWithPath: "output/timeline.json"))
let timeline = try JSONSerialization.jsonObject(with: timelineData) as! [String: Any]
let clips = timeline["clips"] as! [[String: Any]]
let expectedDuration = timeline["duration"] as! Double
let expectedAudioStart = clips.first!["start"] as! Double
let expectedAudioEnd = clips.last!["end"] as! Double
let videoEnd = CMTimeGetSeconds(video.timeRange.end)
let audioEnd = CMTimeGetSeconds(audio.timeRange.end)
let audioStart = CMTimeGetSeconds(audio.timeRange.start)
let width = Int(video.naturalSize.width)
let height = Int(video.naturalSize.height)
guard width == 1920, height == 1080, abs(video.nominalFrameRate - 24) < 0.01 else {
    fatalError("尺寸或帧率不符合要求")
}
guard abs(duration - expectedDuration) < 0.10, abs(videoEnd - duration) < 0.10,
      abs(audioEnd - expectedAudioEnd) < 0.10, audioStart >= 0 && audioStart <= expectedAudioStart + 0.10 else {
    fatalError("音视频未覆盖完整旁白：videoEnd=\(videoEnd), audioStart=\(audioStart), audioEnd=\(audioEnd), duration=\(duration)")
}
try fm.createDirectory(atPath: "output/qa", withIntermediateDirectories: true)
let generator = AVAssetImageGenerator(asset: asset)
generator.appliesPreferredTrackTransform = true
generator.requestedTimeToleranceBefore = .zero
generator.requestedTimeToleranceAfter = .zero
var frames: [[String: Any]] = []
for seconds in [10.0, 90.0, 250.0, max(0, duration - 0.25)] {
    var actual = CMTime.zero
    let image = try generator.copyCGImage(at: CMTime(seconds: seconds, preferredTimescale: 24), actualTime: &actual)
    let filename = String(format: "output/qa/frame-%06.2fs.png", seconds)
    let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: filename) as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { fatalError("抽帧失败") }
    frames.append(["requested": seconds, "actual": CMTimeGetSeconds(actual), "path": filename])
    print("实际成片抽帧：\(filename)")
}
let reader = try AVAssetReader(asset: asset)
let audioOutput = AVAssetReaderTrackOutput(track: audio, outputSettings: [
    AVFormatIDKey: kAudioFormatLinearPCM,
    AVLinearPCMIsFloatKey: true,
    AVLinearPCMBitDepthKey: 32,
    AVLinearPCMIsNonInterleaved: false
])
reader.add(audioOutput)
guard reader.startReading() else { fatalError("无法解码成片音轨：\(reader.error?.localizedDescription ?? "未知错误")") }
var peak: Float = 0
var squares: Double = 0
var sampleCount: Int64 = 0
var nonSilentSamples: Int64 = 0
var clippedSamples: Int64 = 0
while let sampleBuffer = audioOutput.copyNextSampleBuffer() {
    guard let block = CMSampleBufferGetDataBuffer(sampleBuffer) else { fatalError("音频样本没有数据") }
    let bytes = CMBlockBufferGetDataLength(block)
    var samples = [Float](repeating: 0, count: bytes / MemoryLayout<Float>.size)
    let status = samples.withUnsafeMutableBytes { raw in
        CMBlockBufferCopyDataBytes(block, atOffset: 0, dataLength: bytes, destination: raw.baseAddress!)
    }
    guard status == noErr else { fatalError("无法读取 PCM 数据") }
    for value in samples {
        let magnitude = abs(value)
        peak = max(peak, magnitude)
        squares += Double(value) * Double(value)
        sampleCount += 1
        if magnitude > 0.00001 { nonSilentSamples += 1 }
        if magnitude >= 0.999 { clippedSamples += 1 }
    }
}
guard reader.status == .completed, sampleCount > 0, peak > 0.005, nonSilentSamples > 100 else {
    fatalError("音频解码失败或没有有效声音")
}
let rms = sqrt(squares / Double(sampleCount))
func codec(_ descriptions: [Any]) -> [String] {
    descriptions.map {
        let code = CMFormatDescriptionGetMediaSubType($0 as! CMFormatDescription)
        return String(bytes: [UInt8((code >> 24) & 255), UInt8((code >> 16) & 255), UInt8((code >> 8) & 255), UInt8(code & 255)], encoding: .ascii) ?? "unknown"
    }
}
let report: [String: Any] = [
    "file": path, "width": width, "height": height, "fps": video.nominalFrameRate,
    "duration": duration, "videoTrackCount": videoTracks.count, "audioTrackCount": audioTracks.count,
    "videoEnd": videoEnd, "audioStart": audioStart, "audioEnd": audioEnd,
    "expectedAudioStart": expectedAudioStart, "expectedAudioEnd": expectedAudioEnd,
    "audioCoverage": "All narration is present; the intentional final 1.2-second pause contains no audio packets.",
    "videoCodecs": codec(video.formatDescriptions), "audioCodecs": codec(audio.formatDescriptions),
    "decodedAudioSamples": sampleCount, "nonSilentSamples": nonSilentSamples,
    "peakAmplitude": peak, "peakDBFS": 20 * log10(Double(peak)), "rmsAmplitude": rms,
    "rmsDBFS": 20 * log10(rms), "samplesAtOrAbove0.999": clippedSamples,
    "frames": frames,
    "bytes": try fm.attributesOfItem(atPath: path)[.size] ?? 0,
    "passed": true
]
let json = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
try json.write(to: URL(fileURLWithPath: "output/qa/verification.json"))
try json.write(to: URL(fileURLWithPath: "output/media-check.json"))
print(String(data: json, encoding: .utf8)!)
