#!/bin/bash
set -e
NDK="${ANDROID_NDK_HOME:-$ANDROID_HOME/ndk/27.0.12077973}"
LLAMA_DIR="$(cd "$(dirname "$0")/llama.cpp" && pwd)"
BUILD_DIR="$(cd "$(dirname "$0")/../build/android" && pwd)"
mkdir -p "$BUILD_DIR/arm64"
cmake -B "$BUILD_DIR/arm64" -S "$LLAMA_DIR" \
  -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
  -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-24 \
  -DGGML_OPENMP=OFF -DGGML_NATIVE=OFF -DBUILD_SHARED_LIBS=ON
cmake --build "$BUILD_DIR/arm64" -j"$(nproc)"
echo "Android build complete: $BUILD_DIR/arm64"
