// SPDX-License-Identifier: LGPL-3.0-only
// Microsoft Edge Read Aloud wire protocol interoperability.
// Protocol reference: https://github.com/rany2/edge-tts (LGPL-3.0).
// No account credentials or API keys are read. The public client token is a protocol constant.
import Foundation

struct NeuralBoundary: Codable {
    let text: String
    let offset: Double
    let duration: Double
}
struct NeuralResult {
    let audio: Data
    let boundaries: [NeuralBoundary]
}
enum NeuralVoiceError: Error, CustomStringConvertible {
    case failed(String)
    var description: String { switch self { case .failed(let text): return text } }
}
enum NeuralVoice {
    static let identifier = "zh-CN-XiaoxiaoNeural"
    static let displayName = "Microsoft 晓晓（神经语音）"
    static let provider = "Microsoft Edge Read Aloud"
    static let rate = "-5%"
    static let publicClientToken = "6A5AA1D4EAFF4E9FB37E23D68491D6F4"
    static func uuid() -> String { UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased() }
    static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE MMM dd yyyy HH:mm:ss 'GMT+0000 (Coordinated Universal Time)'"
        return formatter.string(from: Date())
    }
    static func escaped(_ input: String) -> String {
        input.replacingOccurrences(of: "&", with: "&amp;")
             .replacingOccurrences(of: "<", with: "&lt;")
             .replacingOccurrences(of: ">", with: "&gt;")
    }
    static func synthesize(_ text: String, token: String) async throws -> NeuralResult {
        let address = "wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1?TrustedClientToken=\(publicClientToken)&ConnectionId=\(uuid())&Sec-MS-GEC=\(token)&Sec-MS-GEC-Version=2-143.0.3650.75"
        var request = URLRequest(url: URL(string: address)!)
        request.timeoutInterval = 45
        request.setValue("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0", forHTTPHeaderField: "User-Agent")
        request.setValue("chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold", forHTTPHeaderField: "Origin")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("en-US,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.setValue("muid=\(uuid().uppercased());", forHTTPHeaderField: "Cookie")
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 45
        configuration.timeoutIntervalForResource = 90
        let session = URLSession(configuration: configuration)
        let socket = session.webSocketTask(with: request)
        socket.maximumMessageSize = 2 * 1024 * 1024
        socket.resume()
        defer { socket.cancel(with: .normalClosure, reason: nil); session.invalidateAndCancel() }
        let config = "X-Timestamp:\(timestamp())\r\nContent-Type:application/json; charset=utf-8\r\nPath:speech.config\r\n\r\n{\"context\":{\"synthesis\":{\"audio\":{\"metadataoptions\":{\"sentenceBoundaryEnabled\":\"true\",\"wordBoundaryEnabled\":\"false\"},\"outputFormat\":\"audio-24khz-48kbitrate-mono-mp3\"}}}}\r\n"
        try await socket.send(.string(config))
        let ssml = "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='zh-CN'><voice name='Microsoft Server Speech Text to Speech Voice (zh-CN, XiaoxiaoNeural)'><prosody pitch='+0Hz' rate='\(rate)' volume='+0%'>\(escaped(text))</prosody></voice></speak>"
        try await socket.send(.string("X-RequestId:\(uuid())\r\nContent-Type:application/ssml+xml\r\nX-Timestamp:\(timestamp())Z\r\nPath:ssml\r\n\r\n\(ssml)"))
        var audio = Data()
        var boundaries: [NeuralBoundary] = []
        while true {
            let message = try await socket.receive()
            switch message {
            case .string(let response):
                guard let delimiter = response.range(of: "\r\n\r\n") else { continue }
                let header = String(response[..<delimiter.lowerBound])
                let body = String(response[delimiter.upperBound...])
                if header.contains("Path:turn.end") {
                    guard audio.count > 1024 else { throw NeuralVoiceError.failed("晓晓服务未返回可用音频；不会回退到系统语音。") }
                    return NeuralResult(audio: audio, boundaries: boundaries)
                }
                if header.contains("Path:audio.metadata"),
                   let json = try JSONSerialization.jsonObject(with: Data(body.utf8)) as? [String: Any],
                   let items = json["Metadata"] as? [[String: Any]] {
                    for item in items where item["Type"] as? String == "SentenceBoundary" {
                        guard let data = item["Data"] as? [String: Any],
                              let offset = data["Offset"] as? Double,
                              let duration = data["Duration"] as? Double,
                              let words = data["text"] as? [String: Any],
                              let wordsText = words["Text"] as? String else { continue }
                        boundaries.append(NeuralBoundary(text: wordsText, offset: offset / 10_000_000, duration: duration / 10_000_000))
                    }
                }
            case .data(let bytes):
                guard bytes.count >= 2 else { continue }
                let length = Int(bytes[bytes.startIndex]) * 256 + Int(bytes[bytes.startIndex + 1])
                guard length + 2 <= bytes.count else { throw NeuralVoiceError.failed("神经配音服务返回了无效音频帧。") }
                let header = String(data: bytes.subdata(in: 2..<(2 + length)), encoding: .utf8) ?? ""
                if header.contains("Path:audio") { audio.append(bytes.subdata(in: (2 + length)..<bytes.count)) }
            @unknown default: break
            }
        }
    }
}
