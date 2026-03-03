# REQUIRES: aarch64

## Test that arm64e creates __auth_got for stub targets and __got for
## address-of-function references. A symbol that is both called and
## has its address taken should appear in both sections.

# RUN: rm -rf %t; split-file %s %t
# RUN: llvm-mc -filetype=obj -triple=arm64e-apple-macos -o %t/foo.o %t/foo.s
# RUN: llvm-mc -filetype=obj -triple=arm64e-apple-macos -o %t/test.o %t/test.s
# RUN: %no-arg-lld -arch arm64e -platform_version macos 13.0 13.0 \
# RUN:   -syslibroot %S/Inputs/MacOSX.sdk -lSystem \
# RUN:   -dylib -install_name @executable_path/libfoo.dylib %t/foo.o -o %t/libfoo.dylib
# RUN: %no-arg-lld -arch arm64e -platform_version macos 13.0 13.0 \
# RUN:   -syslibroot %S/Inputs/MacOSX.sdk -lSystem \
# RUN:   %t/libfoo.dylib %t/test.o -o %t/test

## Verify both __auth_got and __got sections exist.
# RUN: llvm-objdump --macho --all-headers %t/test | FileCheck %s --check-prefix=SECTIONS

# SECTIONS:      sectname __auth_got
# SECTIONS-NEXT: segname __DATA_CONST
# SECTIONS:      sectname __got
# SECTIONS-NEXT: segname __DATA_CONST

## Verify chained fixups contain auth binds (in __auth_got) and
## regular binds (in __got).
# RUN: llvm-objdump --macho --chained-fixups %t/test | FileCheck %s --check-prefix=FIXUPS

# FIXUPS: chained fixups header (LC_DYLD_CHAINED_FIXUPS)
# FIXUPS: pointer_format = 12 (DYLD_CHAINED_PTR_ARM64E_USERLAND24)
# FIXUPS: _foo

#--- foo.s
.globl _foo
_foo:
  ret

#--- test.s
.text
.globl _main

.p2align 2
_main:
  ## Call _foo — this creates a stub, which uses __auth_got.
  bl _foo

  ## Take address of _foo — uses GOT_LOAD, which goes to __got.
  adrp x0, _foo@GOTPAGE
  ldr  x0, [x0, _foo@GOTPAGEOFF]

  ret
