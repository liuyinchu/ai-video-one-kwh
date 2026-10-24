# 一度电如何来到插座 · 第二版

面向大众的中文知识视频，以烧开一壶水为线索，解释一度电、发电、输电损耗、变压器、交流电有效值、电子运动和电网平衡。12 个场景、48 个叙事节拍，画面跟随逐句旁白推进。

当前时间轴长 **276.833 秒（4 分 37 秒）**，输出 1920 × 1080、24 fps、H.264 / AAC MP4；逐句中文字幕同时烧录在视频中，并提供独立 SRT。

## 配音

第二版采用 **Microsoft 晓晓，`zh-CN-XiaoxiaoNeural`，语速 `-5%`**，提供方为 Microsoft Edge Read Aloud。这是神经合成语音，没有使用系统 Tingting，也不是真人录音。

每场作为一个完整段落合成，使句子之间的语气连贯。服务返回的 SentenceBoundary 经过文字匹配后对齐 48 句脚本；必要时可把多个服务句界合并为一条脚本句。本次 12 场全部匹配成功。只有句界无法完整匹配时才使用**同一晓晓音色**逐句合成；服务不可用时明确报错，不会改用系统声音。

`build/neural-audio/` 按声音标识、语速和正文哈希保存 MP3 与句界缓存。重绘画面会复用音频；修改旁白时才需要网络合成。场间留白 0.4 秒，片尾留白约 1.2 秒，没有背景音乐。

30 秒试音为 `output/voice-preview-xiaoxiao.mp3`，实际时长 29.976 秒。

## 文件

- `content/story.json`：12 场、48 句旁白及场景信息。
- `content/script.md`、`content/sources.md`：脚本及科学依据。
- `Sources/Visuals.swift`、`Sources/Art.swift`：逐句动画及原创矢量绘图。
- `Sources/Pipeline.swift`：缓存、时间轴、字幕、预览、视频编码与合成。
- `Sources/NeuralVoice.swift`、`Sources/EdgeToken.swift`：原生 Swift 神经配音接入。
- `Sources/player.html`：视频播放、章节导航、下载与版本对比页。
- `output/一度电如何来到插座.mp4`、`.srt`：最终成片和字幕。
- `output/timeline.json`：真实音频时长、字幕起止、场景时间及明确的 `voiceID` / `provider`。
- `output/storyboard/sceneXX-beatY.png`：48 张分镜，文件编号 Y 从 1 开始。
- `output/storyboard/page-01.png` 至 `page-03.png`：每页 16 张分镜总览。
- `output/qa/`、`output/media-check.json`：成片实际抽帧与媒体检查报告。
- `build/neural-audio/`：第二版神经配音缓存；旧 `build/audio/` 保留第一版系统音频。

`build/` 和 `output/` 是可重新生成的制作产物，不纳入 Git。第三方协议与算法移植来源、适用许可证及完整文本见 [THIRD_PARTY.md](THIRD_PARTY.md)。

## 验证

`./scripts/render.sh --render` 自动运行 `scripts/verify.swift`：核验尺寸、帧率、编码、轨道时长和全部旁白覆盖，解码音轨测量非静音样本、RMS、峰值与削波，并从**实际 MP4**抽取开场、损耗、变压器、有效值、结尾等代表帧。

```sh
/usr/bin/swiftc -O scripts/verify.swift -o build/verify
./build/verify
```

画面入口增加 `beat`（0 至 3）和 `beatProgress`（0 至 1），从实际句界生成，因此每段解释出现时会触发对应动画。片尾有意保留静音画面，音轨结束时间略早于视频总长。
