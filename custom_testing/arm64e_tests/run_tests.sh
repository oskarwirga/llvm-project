#!/usr/bin/env bash
# arm64e_tests/run_tests.sh
# --------------------------------------------------------------
# Verbose harness for the arm64e LLD test‑suite.
#   • Runs every case twice: without LTO and with -flto.
# --------------------------------------------------------------

set -euo pipefail
[[ ${VERBOSE:-0} -ne 0 ]] && set -x           # VERBOSE=1 ./run_tests.sh

declare -a FAILURES=()

ROOT="$(cd "$(dirname "$0")" && pwd)"
source "$ROOT/common.sh"

note()  { echo -e "$*"; }
pass()  { note "✅ $1"; }
fail()  { note "❌ $1"; FAILURES+=("$1"); }

# ---------- helpers ----------------------------------------------------------
compile() {                # $1 = src‑dir   $2 = extra CFLAGS
  $CLANG -target $TARGET -isysroot $SDK $2 -c "$1"/*
}

link_apple() {             # $1 = output    $2 = ldflags   $3 = extra LDFLAGS
  $CLANG -target $TARGET -isysroot $SDK *.o -o "$1.apple" $2 $3
}
link_lld() {               # $1 = output    $2 = ldflags   $3 = extra LDFLAGS
  $CLANG -target $TARGET -isysroot $SDK -fuse-ld=$LLD *.o -o "$1.lld" $2 $3
}

compare_headers() { diff \
  <(otool -hv "$1.apple" | sed '1s/^[^:]*:/X:/') \
  <(otool -hv "$1.lld"   | sed '1s/^[^:]*:/X:/'); }
compare_relocs()  { diff \
  <($LLVM_OBJDUMP -dr --macho "$1.apple" | sed '1s/^[^:]*:/X:/') \
  <($LLVM_OBJDUMP -dr --macho "$1.lld"   | sed '1s/^[^:]*:/X:/') >/dev/null; }
compare_fixups()  { diff \
  <(/usr/bin/dyld_info -fixups "$1.apple" | sed '1s/^[^:]*:/X:/') \
  <(/usr/bin/dyld_info -fixups "$1.lld"   | sed '1s/^[^:]*:/X:/') >/dev/null; }
compare_data()    { diff \
  <(otool -X -s __DATA __data "$1.apple") \
  <(otool -X -s __DATA __data "$1.lld") >/dev/null; }

# ---------- main loop --------------------------------------------------------
for case in "$ROOT/cases"/*; do
  name=$(basename "$case")

  # run twice: without and with LTO
  for MODE in NO-LTO WITH-LTO; do
    build=$(mktemp -d)
    cp "$case"/* "$build"/
    cd "$build"                       # makes debugging easy

    # choose extra flags
    LTO_FLAGS=""
    suffix=""
    if [[ $MODE == WITH-LTO ]]; then
      LTO_FLAGS="-flto"
      suffix=".lto"
    fi

    # -------- determine extra linker flags ----------
    extra_link_flags=""
    shopt -s nullglob
    mfiles=(*.m)
    cppfiles=(*.cpp *.cc *.cxx)
    (( ${#mfiles[@]} ))  && extra_link_flags+=" -framework Foundation"
    (( ${#cppfiles[@]} )) && extra_link_flags+=" -lc++"
    shopt -u nullglob

    # -------- compilation & linking ----------
    compile . "$LTO_FLAGS"             || { fail "$name [$MODE]: compile error"; continue; }
    link_apple "$name$suffix" "$extra_link_flags" "$LTO_FLAGS" \
                                      || { fail "$name [$MODE]: Apple link error"; continue; }
    link_lld   "$name$suffix" "$extra_link_flags" "$LTO_FLAGS" \
                                      || { fail "$name [$MODE]: LLD link error";   continue; }

    $CODESIGN -s - "$name$suffix.apple" >/dev/null 2>&1 || true
    $CODESIGN -s - "$name$suffix.lld"   >/dev/null 2>&1 || true

    # -------- comparisons ----------
    if ! compare_headers "$name$suffix"; then
      fail "$name [$MODE]: header mismatch"; continue
    fi

    if [[ $name == "func_ptr" || $name == "ext_func" ]]; then
      compare_relocs "$name$suffix" || fail "$name [$MODE]: reloc mismatch"
    fi

    compare_fixups "$name$suffix" || fail "$name [$MODE]: fixup mismatch"
    compare_data  "$name$suffix"  || fail "$name [$MODE]: data mismatch"

    case " ${FAILURES[*]-} " in
      *" $name [$MODE]:"*) ;;          # already recorded as failed
      *) pass "$name [$MODE]" ;;
    esac
  done
done

# ---------- summary ----------------------------------------------------------
if ((${#FAILURES[@]})); then
  note "\nFailed cases:"
  for f in "${FAILURES[@]}"; do note "  • $f"; done
  exit 1
fi

note "\nAll tests passed ✔︎"
