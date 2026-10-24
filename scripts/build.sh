#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR/.."
mkdir -p build
/usr/bin/swiftc -O -framework AVFoundation -framework AppKit -framework CoreGraphics -framework CoreVideo -framework CoreMedia -framework ImageIO -framework UniformTypeIdentifiers Sources/*.swift -o build/render
printf '已构建：%s/build/render\n' "$PWD"
