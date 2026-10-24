#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR/.."
./scripts/build.sh
if [ "$#" -eq 0 ]; then set -- --render; fi
./build/render "$@"
for argument in "$@"; do
  if [ "$argument" = "--render" ]; then
    /usr/bin/swiftc -O scripts/verify.swift -o build/verify
    ./build/verify
    if [ -f Sources/player.html ]; then cp Sources/player.html output/index.html; fi
    ln -sfn '一度电如何来到插座.mp4' output/one-kwh.mp4
    ln -sfn '一度电如何来到插座.srt' output/subtitles.srt
    for document in script.md sources.md; do
      if [ -f "content/$document" ]; then cp "content/$document" "output/$document"; fi
    done
    printf '播放器与下载文件已同步到 output/。\n'
    break
  fi
done
