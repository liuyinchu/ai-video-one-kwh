// SPDX-License-Identifier: LGPL-3.0-only
// Swift adaptation of rany2/edge-tts, src/edge_tts/drm.py (retrieved 2026-10-24):
// https://github.com/rany2/edge-tts/blob/master/src/edge_tts/drm.py
// Original project: https://github.com/rany2/edge-tts ; license: LGPL-3.0.
// Adaptation: uses UInt32 wrapping operations and ordinary SHA-256 round loops,
// preserving the upstream v2 modified initial state, schedule and CS64 digest.
// This source implements public client-token formatting, not general SHA-256.
import Foundation

private enum EdgeTokenV2 {
    static let clientToken = "6A5AA1D4EAFF4E9FB37E23D68491D6F4"
    static let initial: [UInt32] = [
        0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A,
        0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19
    ]
    static let resumedState: [UInt32] = [
        0xFD9FBEA2, 0x91243CE7, 0xBE499094, 0xCD2E1E0A,
        0x6C006F49, 0x04BD35AB, 0xFEB0A7E4, 0x03EFFBD2
    ]
    static let schedule: [UInt32] = [
        0xEB24BF9E, 0x1558691F, 0xA0C09EE2, 0x0CFA32BA,
        0xA622EE8C, 0xD1DD9491, 0xC0DD25A0, 0xF9E70AB6,
        0xF0C31573, 0x7058CE4E, 0x7188E606, 0x00E5AB33,
        0xD258B060, 0x72766564
    ]
    static let constants: [UInt32] = [
        0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5,
        0x3956C25B, 0x59F111F1, 0x923F82A4, 0xAB1C5ED5,
        0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3,
        0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174,
        0xE49B69C1, 0xEFBE4786, 0x0FC19DC6, 0x240CA1CC,
        0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA,
        0x983E5152, 0xA831C66D, 0xB00327C8, 0xBF597FC7,
        0xC6E00BF3, 0xD5A79147, 0x06CA6351, 0x14292967,
        0x27B70A85, 0x2E1B2138, 0x4D2C6DFC, 0x53380D13,
        0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85,
        0xA2BFE8A1, 0xA81A664B, 0xC24B8B70, 0xC76C51A3,
        0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070,
        0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5,
        0x391C0CB3, 0x4ED8AA4A, 0x5B9CCA4F, 0x682E6FF3,
        0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208,
        0x90BEFFFA, 0xA4506CEB, 0xBEF9A3F7, 0xC67178F2
    ]
    static let coefficients: [(UInt32, UInt32)] = [
        (0xE82E91B1, 0xB32700D0), (0x44DE24C6, 0x88DFF51D),
        (0x3BEB65BC, 0x29514038), (0xC89C5933, 0xB328CBDF),
        (0x8D1EC211, 0xD405B4D5), (0x314EF5D5, 0x26E55F3C),
        (0xE92491B1, 0x607801C6), (0xF0A5B9D5, 0x82B2C1FB),
        (0x06064CF3, 0xFA51A3DA), (0xDA79FA60, 0x207CC464),
        (0xBED20560, 0x3C3C74F3), (0x89F9C9F8, 0xD2D14B61),
        (0x35FA38C6, 0xBB04A2C1), (0xCB49E3C6, 0xC5626167)
    ]
    static func rotr(_ value: UInt32, _ count: UInt32) -> UInt32 {
        (value >> count) | (value << (32 - count))
    }
    static func rol16(_ value: UInt32) -> UInt32 { (value << 16) | (value >> 16) }
    static func sigma0(_ value: UInt32) -> UInt32 {
        rotr(value, 7) ^ rotr(value, 18) ^ (value >> 3)
    }
    static func sigma1(_ value: UInt32) -> UInt32 {
        rotr(value, 17) ^ rotr(value, 19) ^ (value >> 10)
    }
    static func wordBE(_ bytes: ArraySlice<UInt8>) -> UInt32 {
        bytes.reduce(UInt32(0)) { ($0 << 8) | UInt32($1) }
    }
    static func wordLE(_ bytes: ArraySlice<UInt8>) -> UInt32 {
        bytes.enumerated().reduce(UInt32(0)) { $0 | (UInt32($1.element) << UInt32($1.offset * 8)) }
    }
    static func expand(_ words: inout [UInt32], from first: Int = 16) {
        for i in first..<64 {
            words.append(sigma1(words[i - 2]) &+ words[i - 7] &+ sigma0(words[i - 15]) &+ words[i - 16])
        }
    }
    static func rounds(_ state: [UInt32], words: [UInt32], first: Int = 0) -> [UInt32] {
        var a = state[0], b = state[1], c = state[2], d = state[3]
        var e = state[4], f = state[5], g = state[6], h = state[7]
        for i in first..<64 {
            let constant: UInt32 = (first == 14 && i == 14) ? 0xC9DC06A7 : constants[i]
            let big1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25)
            let choice = g ^ (e & (f ^ g))
            let t1 = h &+ big1 &+ choice &+ constant &+ words[i]
            let big0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22)
            let majority = (a & b) | (c & (a | b))
            let t2 = big0 &+ majority
            (a, b, c, d, e, f, g, h) = (t1 &+ t2, a, b, c, d &+ t1, e, f, g)
        }
        return [a, b, c, d, e, f, g, h]
    }
    static func initialize(_ data: [UInt8]) -> [UInt32] {
        var words = [UInt32](repeating: 0, count: 14)
        words.append(wordBE(data[0..<3]))
        words.append(wordBE(data[3..<7]))
        for i in 16..<30 {
            var value = schedule[i - 16]
            if i - 2 >= 14 {
                value = value &+ (sigma1(words[i - 2]) ^ (i == 16 ? UInt32(0x000B92C0) : 0))
            }
            if i - 7 >= 14 { value = value &+ words[i - 7] }
            if i - 15 >= 14 {
                value = value &+ (sigma0(words[i - 15]) ^ (i == 29 ? UInt32(0x059C0B80) : 0))
            }
            words.append(value)
        }
        words.append(sigma1(words[28]) &+ words[23] &+ sigma0(words[15]) &+ words[14] &+ 0xC9DC06A7 &- constants[14])
        expand(&words, from: 31)
        let working = rounds(resumedState, words: words, first: 14)
        return zip(initial, working).map { $0 &+ $1 }
    }
    static func sha256(_ data: [UInt8]) -> [UInt8] {
        precondition(data.count >= 7)
        let length = 57 + data.count
        var padded = Array(data.dropFirst(7))
        padded.append(0x80)
        padded.append(contentsOf: repeatElement(UInt8(0), count: ((55 - length) % 64 + 64) % 64))
        let bitLength = UInt64(length) * 8
        for shift in stride(from: 56, through: 0, by: -8) {
            padded.append(UInt8(truncatingIfNeeded: bitLength >> UInt64(shift)))
        }
        var state = initialize(data)
        for offset in stride(from: 0, to: padded.count, by: 64) {
            var words = (0..<16).map { wordBE(padded[(offset + $0 * 4)..<(offset + $0 * 4 + 4)]) }
            expand(&words)
            state = zip(state, rounds(state, words: words)).map { $0 &+ $1 }
        }
        return state.flatMap { word in [UInt8(truncatingIfNeeded: word >> 24), UInt8(truncatingIfNeeded: word >> 16), UInt8(truncatingIfNeeded: word >> 8), UInt8(truncatingIfNeeded: word)] }
    }
    static func cs64(_ data: [UInt8], digest: [UInt8]) -> [UInt8] {
        let keyA = wordLE(digest[0..<4]) | 1
        let keyB = wordLE(digest[4..<8]) | 1
        let factors: [UInt32] = [keyA &* 0x82893933, keyB &* 0x82893933]
        var terms = coefficients.enumerated().map { $0.element.0 &* factors[$0.offset % 2] }
        var offsets = coefficients.map { $0.1 }
        var bytes = [UInt8(0)] + data
        bytes.append(contentsOf: repeatElement(UInt8(0), count: (8 - bytes.count % 8) % 8))
        for (i, start) in stride(from: 0, to: bytes.count, by: 4).enumerated() {
            let word = wordLE(bytes[start..<(start + 4)])
            var term = word &* (i % 2 == 0 ? keyA : keyB)
            var offset = rol16(word) &* (i % 2 == 0 ? UInt32(0xEF0569FB) : UInt32(0xC31713DB))
            if i == 0 { term = term &+ (0xF2F90B1A &* factors[0]); offset = offset &+ 0x0B1A0000 }
            terms.append(term)
            offsets.append(offset)
        }
        var swapAcc: UInt32 = 0, swapLast: UInt32 = 0, state: UInt32 = 0, acc: UInt32 = 0
        for i in stride(from: 0, to: terms.count, by: 2) {
            let x = terms[i], y = terms[i + 1]
            var t = rol16(offsets[i] &+ x)
            var q = t &* 0x76F50F34
            swapAcc = swapAcc &+ (rol16(q) &* 0xC3EFEA97 &+ q)
            t = rol16(offsets[i + 1] &+ y)
            q = t &* 0x1881CE3C
            swapLast = rol16(q) &* 0x35BD1EC9 &+ q
            swapAcc = swapAcc &+ swapLast
            state = state &* keyA &+ x
            state = rol16(state) &* 0xCF98B111
            state = rol16(state) &* 0x87085B9F
            state = rol16(state) &* 0x12CEB96D
            state = rol16(state) &* 0x257E1D83
            acc = acc &+ state
            t = state &* keyB &+ y
            t = rol16(t) &* 0xA27416F5
            t = rol16(t) &* 0xD38396FF
            state = rol16(rol16(t) &* 0x7C932B89) &* 0xBFA49F69
            acc = acc &+ state
        }
        return [swapLast ^ state, swapAcc ^ acc].flatMap { word in
            [UInt8(truncatingIfNeeded: word), UInt8(truncatingIfNeeded: word >> 8), UInt8(truncatingIfNeeded: word >> 16), UInt8(truncatingIfNeeded: word >> 24)]
        }
    }
    static func hex(_ data: [UInt8]) -> String { data.map { String(format: "%02X", $0) }.joined() }
}

/// Edge v2 Sec-MS-GEC token: 16 uppercase CS64 hex digits, a dash, then 64 SHA hex digits.
/// Supply a corrected Unix timestamp here if the server reports clock skew.
public func edgeSecurityToken(unixTimestamp: Double = Date().timeIntervalSince1970) -> String {
    precondition(unixTimestamp.isFinite, "The Edge token timestamp must be finite")
    let windowsSeconds = unixTimestamp + 11_644_473_600
    let bucketSeconds = floor(windowsSeconds / 300) * 300
    let ticks = bucketSeconds * 10_000_000
    let data = Array((String(format: "%.0f", locale: Locale(identifier: "en_US_POSIX"), ticks) + EdgeTokenV2.clientToken).utf8)
    let sha = EdgeTokenV2.sha256(data)
    return EdgeTokenV2.hex(EdgeTokenV2.cs64(data, digest: sha)) + "-" + EdgeTokenV2.hex(sha)
}
