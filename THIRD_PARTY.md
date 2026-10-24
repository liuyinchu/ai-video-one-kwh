# Third-party notices

## edge-tts protocol reference and Swift adaptation

Upstream: [rany2/edge-tts](https://github.com/rany2/edge-tts), maintained by rany and contributors.

The following upstream files were consulted on 2026-10-24, at upstream `master` commit `bd44c1d1aaebdc1db7f47456ee12431b42ec7cac`:

- [`src/edge_tts/drm.py`](https://github.com/rany2/edge-tts/blob/bd44c1d1aaebdc1db7f47456ee12431b42ec7cac/src/edge_tts/drm.py)
- [`src/edge_tts/communicate.py`](https://github.com/rany2/edge-tts/blob/bd44c1d1aaebdc1db7f47456ee12431b42ec7cac/src/edge_tts/communicate.py)
- [`src/edge_tts/constants.py`](https://github.com/rany2/edge-tts/blob/bd44c1d1aaebdc1db7f47456ee12431b42ec7cac/src/edge_tts/constants.py)

`Sources/EdgeToken.swift` adapts the v2 token algorithm from `drm.py` into Swift. It replaces Python integer arithmetic with explicitly wrapping `UInt32` operations and ordinary SHA-256 round loops while preserving the modified initial state, schedule and CS64 computation. The adaptation was made for this project on 2026-10-24 and is provided under **LGPL-3.0-only**.

`Sources/NeuralVoice.swift` implements the WebSocket message framing, service constants and SSML exchange using Apple's native `URLSessionWebSocketTask`, following the upstream protocol implementation. This adaptation is also provided under **LGPL-3.0-only**. Its full source is included so the implementation can be modified and rebuilt with the project using `scripts/build.sh`.

The upstream license states that files other than `srt_composer.py` are licensed under LGPLv3. This project does not use `srt_composer.py` or install/import the Python package. The unmodified upstream license notice is reproduced in [`THIRD_PARTY/edge-tts-LICENSE.txt`](THIRD_PARTY/edge-tts-LICENSE.txt). The GPLv3 text incorporated by LGPLv3 is reproduced in [`THIRD_PARTY/GPL-3.0.txt`](THIRD_PARTY/GPL-3.0.txt).

Microsoft Edge Read Aloud is the external speech provider; the selected voice is `zh-CN-XiaoxiaoNeural` (晓晓). The protocol's public client identifier is a published constant, not a personal credential. The implementation does not read account credentials or API keys.
