# 一度电如何来到插座

面向大众的中文知识视频。通过发电、升压输电、变电配电、用户用电和电网平衡，解释“一度电”这一能量单位以及插座背后的系统。

成片采用 1920 × 1080、24 fps、H.264 / AAC 的 MP4 格式，内嵌逐句中文字幕，并提供独立 SRT 字幕。中文旁白使用 macOS 自带的 **Tingting 系统合成语音**，语速 180；没有背景音乐。每句语音实测时长后再排画面和字幕，句间留 0.16 秒、场间留 0.5 秒。

## 远端环境

本项目的工作目录位于远端 Mac：

```sh
ssh yangshuyun@10.10.10.1
cd ~/workspace/dev/ai-video/ai-video-1024-astra
```

制作使用该机器已有的 macOS 14.4、Apple Swift 5.9、AVFoundation、Core Graphics 和 `/usr/bin/say`。无需安装依赖、Python、Node.js 或 FFmpeg。

## 重新制作

从远端项目根目录运行：

```sh
# 构建并生成所有场景的预览图
./scripts/render.sh --preview

# 只合成旁白、生成准确时间轴及 SRT
./scripts/render.sh --audio-only

# 构建并生成完整成片
./scripts/render.sh --render
```

也可先运行 `./scripts/build.sh`，随后直接调用 `./build/render --preview`、`--audio-only` 或 `--render`。旁白按文本、声音和语速生成稳定缓存；未改变的句子会复用 `build/audio/` 下的 AIFF 文件。画面有修改时可复用音频，重新渲染即可。

正式渲染依次进行语音合成、无声 H.264 编码、旁白合成和 MP4 导出，终端会显示进度。完成后校验视频、音频轨道和总时长。渲染会覆盖同名成片与时间轴。

## 文件说明

- `content/story.json`：标题、场景顺序和逐句旁白。
- `Sources/Visuals.swift`：矢量信息图、动效、标题和字幕绘制。
- `Sources/Pipeline.swift`：语音、时间轴、字幕、预览、视频编码和导出。
- `scripts/build.sh`：调用系统 Swift 编译器。
- `scripts/render.sh`：从项目根目录构建并运行制作管线。
- `output/一度电如何来到插座.mp4`：最终视频，H.264 / AAC。
- `output/一度电如何来到插座.srt`：独立逐句中文字幕。
- `output/timeline.json`：真实音频时长、逐句起止时间和场景时间轴。
- `output/previews/scene-XX.png`：每个场景的全尺寸预览。
- `output/contact-sheet.png`：所有场景的三列总览。
- `build/audio/`：旁白 AIFF 缓存。
- `build/silent-video.mp4`：合成旁白前的临时视频。

`build/` 和 `output/` 为可重新生成的制作产物，不纳入 Git。

## 修改旁白和画面

`story.json` 的 `scenes` 顺序与 `Visuals.swift` 中的场景编号一致；编号从 0 开始。每条 `sentences` 只包含一段 `text`，管线将它视为一个字幕和音频片段。修改场景数量或顺序时，应同步修改绘图逻辑。

绘图入口为：

```swift
func drawFrame(_ context: CGContext, width: Int, height: Int,
               scene: Int, progress: Double, subtitle: String,
               elapsed: Double, total: Double)
```

`progress` 为当前场景内 0 至 1 的进度；`elapsed` 和 `total` 为全片的秒数。预览采用每场进度 0.5；最终视频按真实旁白时间轴逐帧绘制。

## 成片播放页

`Sources/player.html` 是播放页源码。正式制作成功后，`scripts/render.sh` 会同步到 `output/index.html`，建立便于下载的 `one-kwh.mp4`、`subtitles.srt` 链接，并复制脚本与事实来源文档。播放页读取 `timeline.json`，支持按场景跳转。

在远端项目根目录启动只监听本机的 HTTP 服务：

```sh
VIDEO_PORT=18326 /usr/bin/ruby scripts/serve.rb
```

在本地另一个终端建立 SSH 隧道：

```sh
ssh -N -L127.0.0.1:18326:127.0.0.1:18326 yangshuyun@10.10.10.1
```

保持两者运行，再访问 <http://127.0.0.1:18326/>。服务和全部制作文件仍在远端，SSH 隧道仅用于本地访问。

## 成片验证

正式制作后自动编译并运行 `scripts/verify.swift`，直接从最终 MP4 抽帧到 `output/qa/`，并生成 `output/media-check.json` 与 `output/qa/verification.json`。验证包含 1080p / 24 fps、H.264 / AAC 轨道、总时长、旁白覆盖、解码音频的非静音样本数、RMS 和峰值。

也可独立重跑：

```sh
/usr/bin/swiftc -O scripts/verify.swift -o build/verify
./build/verify
```

当前成片长 258.958 秒（4 分 19 秒），共 6,215 帧，文件约 29.2 MB。音轨完整覆盖全部旁白；最后约 1.2 秒为有意保留的静音画面，容器和视频轨道仍持续到全片末尾。
