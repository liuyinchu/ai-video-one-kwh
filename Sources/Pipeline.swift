import Foundation
import AVFoundation
import AppKit
import CoreGraphics
import CoreVideo
import CoreMedia
import ImageIO
import UniformTypeIdentifiers
import Darwin

private let canvasWidth = 1920
private let canvasHeight = 1080
private let frameRate: Int32 = 24
private let voice = NeuralVoice.displayName
private let voiceRate = NeuralVoice.rate
private let fm = FileManager.default

struct Story: Decodable {
    let title: String
    let subtitle: String?
    let scenes: [StoryScene]
}
struct StoryScene: Decodable {
    let title: String
    let kicker: String?
    let sentences: [StorySentence]
}
struct StorySentence: Decodable { let text: String }
struct SentenceClip: Codable {
    let scene: Int
    let sentence: Int
    let text: String
    let start: Double
    let end: Double
    let audioPath: String
}
struct AudioSegment: Codable {
    let scene: Int
    let start: Double
    let end: Double
    let audioPath: String
}
struct SceneTiming: Codable {
    let scene: Int
    let title: String
    let start: Double
    let end: Double
}
struct Timeline: Codable {
    let title: String
    let voice: String
    let voiceID: String
    let provider: String
    let voiceRate: String
    let width: Int
    let height: Int
    let fps: Int
    let duration: Double
    let scenes: [SceneTiming]
    let clips: [SentenceClip]
    let audioSegments: [AudioSegment]
}

enum PipelineError: Error, CustomStringConvertible {
    case message(String)
    var description: String { switch self { case .message(let text): return text } }
}

private func fail(_ message: String) -> PipelineError { .message(message) }
private func log(_ message: String) { print(message); fflush(stdout) }
private func url(_ path: String) -> URL { URL(fileURLWithPath: path) }
private func ensureDirectories() throws {
    for path in ["build/neural-audio", "output/previews", "output/storyboard"] {
        try fm.createDirectory(atPath: path, withIntermediateDirectories: true)
    }
}
private func readStory() throws -> Story {
    let story = try JSONDecoder().decode(Story.self, from: Data(contentsOf: url("content/story.json")))
    guard !story.scenes.isEmpty else { throw fail("content/story.json 没有场景。") }
    for (i, scene) in story.scenes.enumerated() {
        guard !scene.sentences.isEmpty, scene.sentences.allSatisfy({ !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            throw fail("第 \(i + 1) 场没有有效旁白。")
        }
    }
    return story
}
private func stableHash(_ text: String) -> String {
    var value: UInt64 = 14_695_981_039_346_656_037
    for byte in text.utf8 { value = (value ^ UInt64(byte)) &* 1_099_511_628_211 }
    return String(value, radix: 16)
}
private func loadNeuralAudio(text: String, stem: String) async throws -> (String, [NeuralBoundary]) {
    let hash = stableHash("\(NeuralVoice.identifier)|\(voiceRate)|\(text)")
    let path = "build/neural-audio/\(stem)-\(hash).mp3"
    let boundaryPath = path + ".boundaries.json"
    if fm.fileExists(atPath: path), fm.fileExists(atPath: boundaryPath),
       let data = try? Data(contentsOf: url(boundaryPath)),
       let boundaries = try? JSONDecoder().decode([NeuralBoundary].self, from: data),
       (try? audioDuration(path)) != nil {
        return (path, boundaries)
    }
    var lastError: Error?
    for attempt in 1...3 {
        do {
            let result = try await NeuralVoice.synthesize(text, token: edgeSecurityToken())
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try result.audio.write(to: url(path), options: .atomic)
            try encoder.encode(result.boundaries).write(to: url(boundaryPath), options: .atomic)
            return (path, result.boundaries)
        } catch {
            lastError = error
            if attempt < 3 {
                log("  网络合成暂未完成，重试 \(attempt)/2；声音保持 \(NeuralVoice.identifier)。")
                try await Task.sleep(nanoseconds: UInt64(attempt) * 1_000_000_000)
            }
        }
    }
    throw fail("Microsoft 晓晓神经配音合成失败，未回退系统声音：\(lastError!)")
}
private func normalizedBoundaryText(_ text: String) -> String {
    String(String.UnicodeScalarView(text.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) }))
}
private func matchedBoundaries(_ boundaries: [NeuralBoundary], sentences: [StorySentence]) -> [NeuralBoundary]? {
    var result: [NeuralBoundary] = []
    var index = 0
    for sentence in sentences {
        let target = normalizedBoundaryText(sentence.text)
        var collected = ""
        let firstIndex = index
        while index < boundaries.count && collected != target {
            collected += normalizedBoundaryText(boundaries[index].text)
            index += 1
            guard target.hasPrefix(collected) else { return nil }
        }
        guard collected == target, index > firstIndex else { return nil }
        let first = boundaries[firstIndex]
        let last = boundaries[index - 1]
        result.append(NeuralBoundary(text: sentence.text, offset: first.offset,
                                    duration: last.offset + last.duration - first.offset))
    }
    return index == boundaries.count ? result : nil
}
private func audioDuration(_ path: String) throws -> Double {
    let asset = AVURLAsset(url: url(path))
    let duration = CMTimeGetSeconds(asset.duration)
    guard duration.isFinite, duration > 0, !asset.tracks(withMediaType: .audio).isEmpty else {
        throw fail("无法读取音频：\(path)")
    }
    return duration
}
private func srtTimestamp(_ seconds: Double) -> String {
    let milliseconds = max(0, Int((seconds * 1000).rounded()))
    return String(format: "%02d:%02d:%02d,%03d", milliseconds / 3_600_000,
                  milliseconds / 60_000 % 60, milliseconds / 1_000 % 60, milliseconds % 1_000)
}
private func prepareTimeline(story: Story) async throws -> Timeline {
    var clips: [SentenceClip] = []
    var timings: [SceneTiming] = []
    var segments: [AudioSegment] = []
    var cursor = 0.45
    let count = story.scenes.reduce(0) { $0 + $1.sentences.count }
    log("[1/4] 神经配音：\(voice) · \(NeuralVoice.identifier) · 语速 \(voiceRate) · \(count) 句。")
    log("  优先整场连续合成，以服务端句界同步字幕；不使用系统合成声音。")
    for (sceneIndex, scene) in story.scenes.enumerated() {
        let sceneStart = sceneIndex == 0 ? 0 : cursor
        let text = scene.sentences.map(\.text).joined(separator: " ")
        let (path, boundaries) = try await loadNeuralAudio(text: text, stem: String(format: "scene-%02d", sceneIndex + 1))
        let duration = try audioDuration(path)
        if let matched = matchedBoundaries(boundaries, sentences: scene.sentences) {
            let audioStart = cursor
            segments.append(AudioSegment(scene: sceneIndex, start: audioStart, end: audioStart + duration, audioPath: path))
            for (sentenceIndex, boundary) in matched.enumerated() {
                let nextStart = sentenceIndex + 1 < matched.count ? matched[sentenceIndex + 1].offset : duration
                let end = min(duration, nextStart, boundary.offset + boundary.duration)
                guard end > boundary.offset else { throw fail("第 \(sceneIndex + 1) 场句界时间无效。") }
                clips.append(SentenceClip(scene: sceneIndex, sentence: sentenceIndex, text: scene.sentences[sentenceIndex].text,
                                          start: audioStart + boundary.offset, end: audioStart + end, audioPath: path))
            }
            cursor += duration
            log(String(format: "  第 %02d/%02d 场 · 连续配音 %.2f 秒 · %d 条精确句界", sceneIndex + 1, story.scenes.count, duration, matched.count))
        } else {
            log("  第 \(sceneIndex + 1) 场的服务端分句无法完整匹配，改用同一晓晓音色逐句合成。")
            for (sentenceIndex, sentence) in scene.sentences.enumerated() {
                let (sentencePath, sentenceBoundaries) = try await loadNeuralAudio(text: sentence.text,
                    stem: String(format: "sentence-%02d-%02d", sceneIndex + 1, sentenceIndex + 1))
                let sentenceDuration = try audioDuration(sentencePath)
                let firstOffset = max(0, sentenceBoundaries.first?.offset ?? 0)
                let lastBoundary = sentenceBoundaries.last
                let speechEnd = min(sentenceDuration, lastBoundary.map { $0.offset + $0.duration } ?? sentenceDuration)
                segments.append(AudioSegment(scene: sceneIndex, start: cursor, end: cursor + sentenceDuration, audioPath: sentencePath))
                clips.append(SentenceClip(scene: sceneIndex, sentence: sentenceIndex, text: sentence.text,
                    start: cursor + firstOffset, end: cursor + max(firstOffset + 0.05, speechEnd), audioPath: sentencePath))
                cursor += sentenceDuration
                if sentenceIndex + 1 < scene.sentences.count { cursor += 0.10 }
            }
        }
        cursor += sceneIndex + 1 < story.scenes.count ? 0.40 : 1.20
        timings.append(SceneTiming(scene: sceneIndex, title: scene.title, start: sceneStart, end: cursor))
    }
    let exactDuration = ceil(cursor * Double(frameRate)) / Double(frameRate)
    if let last = timings.last {
        timings[timings.count - 1] = SceneTiming(scene: last.scene, title: last.title, start: last.start, end: exactDuration)
    }
    let timeline = Timeline(title: story.title, voice: voice, voiceID: NeuralVoice.identifier, provider: NeuralVoice.provider,
                            voiceRate: voiceRate, width: canvasWidth, height: canvasHeight, fps: Int(frameRate),
                            duration: exactDuration, scenes: timings, clips: clips, audioSegments: segments)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    try encoder.encode(timeline).write(to: url("output/timeline.json"), options: .atomic)
    let srt = clips.enumerated().map { index, clip in
        "\(index + 1)\n\(srtTimestamp(clip.start)) --> \(srtTimestamp(clip.end))\n\(clip.text)\n"
    }.joined(separator: "\n")
    try srt.write(to: url("output/一度电如何来到插座.srt"), atomically: true, encoding: .utf8)
    log(String(format: "  时间轴完成：%.2f 秒（%d 帧），%d 个音频片段。", exactDuration,
               Int((exactDuration * Double(frameRate)).rounded()), segments.count))
    return timeline
}

private func bitmapContext(width: Int, height: Int) throws -> CGContext {
    guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                                  bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
        throw fail("无法创建画布。")
    }
    return context
}
private func savePNG(_ image: CGImage, path: String) throws {
    guard let destination = CGImageDestinationCreateWithURL(url(path) as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        throw fail("无法保存预览图：\(path)")
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { throw fail("预览图编码失败：\(path)") }
}
private func preview(story: Story) throws {
    log("预览：\(story.scenes.count) 个场景，\(canvasWidth) × \(canvasHeight)，每场 4 个叙事节拍。")
    let columns = 3
    let thumbWidth = 640
    let thumbHeight = 360
    let rows = (story.scenes.count + columns - 1) / columns
    let sheet = try bitmapContext(width: columns * thumbWidth, height: rows * thumbHeight)
    for (index, scene) in story.scenes.enumerated() {
        let context = try bitmapContext(width: canvasWidth, height: canvasHeight)
        drawFrame(context, width: canvasWidth, height: canvasHeight, scene: index, progress: 0.5,
                  subtitle: scene.sentences[min(2, scene.sentences.count - 1)].text, elapsed: Double(index) * 25 + 12.5,
                  total: Double(story.scenes.count) * 25, beat: 2, beatProgress: 0.5)
        guard let image = context.makeImage() else { throw fail("第 \(index + 1) 场预览生成失败。") }
        let path = String(format: "output/previews/scene-%02d.png", index + 1)
        try savePNG(image, path: path)
        let row = index / columns
        let col = index % columns
        sheet.draw(image, in: CGRect(x: col * thumbWidth, y: (rows - row - 1) * thumbHeight, width: thumbWidth, height: thumbHeight))
        log("  \(path)")
    }
    guard let image = sheet.makeImage() else { throw fail("联系表生成失败。") }
    try savePNG(image, path: "output/contact-sheet.png")
    let storyboardCount = story.scenes.count * 4
    let pages = (storyboardCount + 15) / 16
    for page in 0..<pages {
        let board = try bitmapContext(width: 1920, height: 1080)
        board.setFillColor(CGColor(gray: 0.04, alpha: 1))
        board.fill(CGRect(x: 0, y: 0, width: 1920, height: 1080))
        for cell in 0..<16 {
            let frame = page * 16 + cell
            guard frame < storyboardCount else { break }
            let sceneIndex = frame / 4
            let beat = frame % 4
            let scene = story.scenes[sceneIndex]
            let context = try bitmapContext(width: canvasWidth, height: canvasHeight)
            let progress = (Double(beat) + 0.5) / 4
            drawFrame(context, width: canvasWidth, height: canvasHeight, scene: sceneIndex, progress: progress,
                      subtitle: scene.sentences[min(beat, scene.sentences.count - 1)].text,
                      elapsed: (Double(sceneIndex) + progress) * 25, total: Double(story.scenes.count) * 25,
                      beat: beat, beatProgress: 0.5)
            guard let frameImage = context.makeImage() else { throw fail("分镜预览生成失败。") }
            let path = String(format: "output/storyboard/scene%02d-beat%d.png", sceneIndex + 1, beat + 1)
            try savePNG(frameImage, path: path)
            board.draw(frameImage, in: CGRect(x: (cell % 4) * 480, y: (3 - cell / 4) * 270, width: 480, height: 270))
        }
        guard let boardImage = board.makeImage() else { throw fail("分镜联系表生成失败。") }
        let path = String(format: "output/storyboard/page-%02d.png", page + 1)
        try savePNG(boardImage, path: path)
        log("  \(path)")
    }
    log("预览完成：output/contact-sheet.png 与 output/storyboard/page-01…03.png")
}

private func renderVideo(timeline: Timeline) throws -> URL {
    let output = url("build/silent-video.mp4")
    if fm.fileExists(atPath: output.path) { try fm.removeItem(at: output) }
    let writer = try AVAssetWriter(outputURL: output, fileType: .mp4)
    let settings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: canvasWidth, AVVideoHeightKey: canvasHeight,
        AVVideoCompressionPropertiesKey: [
            AVVideoAverageBitRateKey: 6_000_000,
            AVVideoExpectedSourceFrameRateKey: Int(frameRate),
            AVVideoMaxKeyFrameIntervalKey: Int(frameRate * 2),
            AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
        ],
        AVVideoColorPropertiesKey: [AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
                                   AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
                                   AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2]
    ]
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    input.expectsMediaDataInRealTime = false
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        kCVPixelBufferWidthKey as String: canvasWidth,
        kCVPixelBufferHeightKey as String: canvasHeight,
        kCVPixelBufferCGImageCompatibilityKey as String: true,
        kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
        kCVPixelBufferIOSurfacePropertiesKey as String: [:]
    ])
    guard writer.canAdd(input) else { throw fail("视频编码器无法添加输入。") }
    writer.add(input)
    guard writer.startWriting() else { throw fail("无法启动 H.264 编码：\(writer.error?.localizedDescription ?? "未知错误")") }
    writer.startSession(atSourceTime: .zero)
    guard let pool = adaptor.pixelBufferPool else { throw fail("无法创建视频帧缓冲池。") }
    let frames = Int((timeline.duration * Double(frameRate)).rounded())
    var sceneIndex = 0
    var clipIndex = 0
    let began = Date()
    log("[2/4] 渲染 H.264 视频：\(frames) 帧，\(canvasWidth) × \(canvasHeight)，\(frameRate) fps。")
    for frame in 0..<frames {
        try autoreleasepool {
            let elapsed = Double(frame) / Double(frameRate)
            while sceneIndex + 1 < timeline.scenes.count && elapsed >= timeline.scenes[sceneIndex].end { sceneIndex += 1 }
            while clipIndex + 1 < timeline.clips.count && elapsed >= timeline.clips[clipIndex + 1].start { clipIndex += 1 }
            let scene = timeline.scenes[sceneIndex]
            let clip = timeline.clips[clipIndex]
            let subtitle = elapsed >= clip.start && elapsed < clip.end ? clip.text : ""
            let progress = min(1, max(0, (elapsed - scene.start) / (scene.end - scene.start)))
            while !input.isReadyForMoreMediaData {
                if writer.status == .failed { throw fail("视频编码失败：\(writer.error?.localizedDescription ?? "未知错误")") }
                Thread.sleep(forTimeInterval: 0.003)
            }
            var buffer: CVPixelBuffer?
            guard CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &buffer) == kCVReturnSuccess,
                  let pixelBuffer = buffer else { throw fail("无法分配视频帧。") }
            CVPixelBufferLockBaseAddress(pixelBuffer, [])
            defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
            guard let context = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer), width: canvasWidth,
                height: canvasHeight, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue) else {
                throw fail("无法创建视频帧画布。")
            }
            drawFrame(context, width: canvasWidth, height: canvasHeight, scene: sceneIndex, progress: progress,
                      subtitle: subtitle, elapsed: elapsed, total: timeline.duration, beat: clip.scene == sceneIndex ? clip.sentence : 0, beatProgress: clip.scene == sceneIndex ? min(1, max(0, (elapsed - clip.start) / (clip.end - clip.start))) : 0)
            context.flush()
            guard adaptor.append(pixelBuffer, withPresentationTime: CMTime(value: Int64(frame), timescale: frameRate)) else {
                throw fail("写入第 \(frame) 帧失败：\(writer.error?.localizedDescription ?? "未知错误")")
            }
        }
        if frame % 120 == 0 || frame + 1 == frames {
            let speed = Double(frame + 1) / max(0.01, Date().timeIntervalSince(began))
            log(String(format: "  视频 %.1f%% · %d/%d 帧 · 第 %02d 场 · %.1f fps", Double(frame + 1) / Double(frames) * 100, frame + 1, frames, sceneIndex + 1, speed))
        }
    }
    writer.endSession(atSourceTime: CMTime(value: Int64(frames), timescale: frameRate))
    input.markAsFinished()
    let finished = DispatchSemaphore(value: 0)
    writer.finishWriting { finished.signal() }
    finished.wait()
    guard writer.status == .completed else { throw fail("完成视频编码失败：\(writer.error?.localizedDescription ?? "未知错误")") }
    return output
}

private func exportFinal(video: URL, timeline: Timeline, story: Story) throws {
    log("[3/4] 合成中文旁白和视频，导出 MP4。")
    let composition = AVMutableComposition()
    guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
          let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
        throw fail("无法创建合成轨道。")
    }
    let videoAsset = AVURLAsset(url: video)
    guard let sourceVideo = videoAsset.tracks(withMediaType: .video).first else { throw fail("无声视频没有视频轨道。") }
    let fullDuration = CMTime(value: Int64((timeline.duration * Double(frameRate)).rounded()), timescale: frameRate)
    try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: fullDuration), of: sourceVideo, at: .zero)
    for clip in timeline.audioSegments {
        let asset = AVURLAsset(url: url(clip.audioPath))
        guard let source = asset.tracks(withMediaType: .audio).first else { throw fail("音频片段没有声音轨道：\(clip.audioPath)") }
        try audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: source,
                                       at: CMTime(seconds: clip.start, preferredTimescale: 60_000))
    }
    // Video retains the final intentional silent pause after the last audio sample.
    let mixParameters = AVMutableAudioMixInputParameters(track: audioTrack)

    mixParameters.setVolume(0.95, at: .zero)
    let mix = AVMutableAudioMix()
    mix.inputParameters = [mixParameters]
    guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset1920x1080) else {
        throw fail("无法创建 MP4 导出器。")
    }
    let destination = url("output/一度电如何来到插座.mp4")
    if fm.fileExists(atPath: destination.path) { try fm.removeItem(at: destination) }
    exporter.outputURL = destination
    exporter.outputFileType = .mp4
    exporter.shouldOptimizeForNetworkUse = true
    exporter.audioMix = mix
    exporter.timeRange = CMTimeRange(start: .zero, duration: fullDuration)
    let titleItem = AVMutableMetadataItem()
    titleItem.identifier = .commonIdentifierTitle
    titleItem.value = story.title as NSString
    let descriptionItem = AVMutableMetadataItem()
    descriptionItem.identifier = .commonIdentifierDescription
    descriptionItem.value = "面向大众的电力科普视频；中文旁白使用 Microsoft 晓晓 zh-CN-XiaoxiaoNeural 神经语音，语速 -5%。" as NSString
    exporter.metadata = [titleItem, descriptionItem]
    let finished = DispatchSemaphore(value: 0)
    exporter.exportAsynchronously { finished.signal() }
    while finished.wait(timeout: .now() + 5) == .timedOut {
        log(String(format: "  MP4 导出 %.1f%%", exporter.progress * 100))
    }
    guard exporter.status == .completed else { throw fail("MP4 导出失败：\(exporter.error?.localizedDescription ?? "未知错误")") }
    try validateFinal(destination, expectedDuration: timeline.duration)
}
private func fourCC(_ code: FourCharCode) -> String {
    let bytes: [UInt8] = [UInt8((code >> 24) & 0xff), UInt8((code >> 16) & 0xff), UInt8((code >> 8) & 0xff), UInt8(code & 0xff)]
    return String(bytes: bytes, encoding: .ascii) ?? "\(code)"
}
private func validateFinal(_ destination: URL, expectedDuration: Double) throws {
    log("[4/4] 检查成片轨道与时长。")
    let asset = AVURLAsset(url: destination)
    guard let video = asset.tracks(withMediaType: .video).first,
          let audio = asset.tracks(withMediaType: .audio).first else { throw fail("成片缺少视频或音频轨道。") }
    let duration = CMTimeGetSeconds(asset.duration)
    guard abs(duration - expectedDuration) < 0.15 else { throw fail("成片时长与时间轴不匹配：\(duration) / \(expectedDuration)") }
    let videoCodecs = video.formatDescriptions.map { fourCC(CMFormatDescriptionGetMediaSubType($0 as! CMFormatDescription)) }
    let audioCodecs = audio.formatDescriptions.map { fourCC(CMFormatDescriptionGetMediaSubType($0 as! CMFormatDescription)) }
    guard videoCodecs.contains("avc1") else { throw fail("成片视频编码不是 H.264：\(videoCodecs)") }
    guard audioCodecs.contains(where: { $0 == "aac " || $0 == "aach" }) else { throw fail("成片音频编码不是 AAC：\(audioCodecs)") }
    let size = try fm.attributesOfItem(atPath: destination.path)[.size] as? Int64 ?? 0
    log(String(format: "完成：%@\n  %.2f 秒 · %.0f × %.0f · %.0f fps · %.1f MB\n  视频 %@，音频 %@", destination.path, duration,
               video.naturalSize.width, video.naturalSize.height, video.nominalFrameRate, Double(size) / 1_000_000,
               videoCodecs.joined(separator: ","), audioCodecs.joined(separator: ",")))
}

@main
struct VideoPipeline {
    static func main() async {
        setbuf(stdout, nil)
        do {
            try ensureDirectories()
            let args = CommandLine.arguments.dropFirst()
            if args.contains("--help") || args.isEmpty {
                log("用法：build/render --preview | --audio-only | --render\n请从仓库根目录运行。--preview 仅生成场景 PNG；--audio-only 仅合成旁白与时间轴；--render 制作完整成片。")
                return
            }
            let story = try readStory()
            if args.contains("--preview") { try preview(story: story); return }
            guard args.contains("--audio-only") || args.contains("--render") else { throw fail("未知参数；使用 --help 查看用法。") }
            let timeline = try await prepareTimeline(story: story)
            if args.contains("--audio-only") { return }
            let video = try renderVideo(timeline: timeline)
            try exportFinal(video: video, timeline: timeline, story: story)
        } catch {
            fputs("错误：\(error)\n", stderr)
            exit(1)
        }
    }
}
