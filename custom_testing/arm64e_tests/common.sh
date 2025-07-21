#!/usr/bin/env bash
# --------- edit these to match your tree ----------
CLANG=${CLANG:-bin/clang}
CLANGXX=${CLANGXX:-bin/clang++}
LLD=${LLD:-bin/ld64.lld}
SDK=${SDK:-/Applications/Xcode_26.0.0_17A5241e.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.0.sdk/}
LLVM_OBJDUMP=${LLVM_OBJDUMP:-llvm-objdump}
TARGET=${TARGET:-arm64e-apple-ios14.3}
CODESIGN=${CODESIGN:-codesign}
TMPROOT=$(mktemp -d)
# --------------------------------------------------
set -euo pipefail
