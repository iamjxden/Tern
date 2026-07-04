#!/bin/bash
set -e
LLAMA_DIR="$(cd "$(dirname "$0")/llama.cpp" && pwd)"
BUILD_DIR="$(cd "$(dirname "$0")/../build/ios" && pwd)"
mkdir -p "$BUILD_DIR"
cmake -B "$BUILD_DIR" -S "$LLAMA_DIR" \
  -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0 -DGGML_METAL=ON \
  -DGGML_OPENMP=OFF -DBUILD_SHARED_LIBS=ON
cmake --build "$BUILD_DIR" -j"$(sysctl -n hw.logicalcpu 2>/dev/null || echo 4)"
echo "iOS build complete: $BUILD_DIR"
