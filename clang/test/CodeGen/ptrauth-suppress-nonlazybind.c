// RUN: %clang_cc1 -triple arm64e-apple-ios -fptrauth-calls -fno-plt -emit-llvm %s -o - | FileCheck %s --check-prefix=PTRAUTH
// RUN: %clang_cc1 -triple arm64-apple-ios -fno-plt -emit-llvm %s -o - | FileCheck %s --check-prefix=NOPTRAUTH
//
// When pointer authentication is enabled (-fptrauth-calls), NonLazyBind
// must NOT be applied. NonLazyBind causes inline GOT loads that bypass
// the linker's authentication stubs, leading to crashes on arm64e where
// GOT entries are PAC-signed.

void external_function(void);

void caller(void) {
  external_function();
}

// With ptrauth enabled, the declaration should NOT have nonlazybind.
// PTRAUTH-NOT: nonlazybind
// PTRAUTH: declare{{.*}} void @external_function()

// Without ptrauth, -fno-plt adds nonlazybind normally.
// NOPTRAUTH: ; Function Attrs:{{.*}}nonlazybind
// NOPTRAUTH: declare{{.*}} void @external_function()
