@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" arm64 > nul 2>&1
set PATH=C:\Users\i-i\.cargo\bin;C:\Users\i-i\.rustup\toolchains\stable-aarch64-pc-windows-msvc\bin;C:\Program Files\LLVM\bin;C:\local\deploy\flutter\bin;%PATH%

cd /d C:\local\prj\RustDesk_arm64\repo

echo === Generating flutter_rust_bridge bindings ===
flutter_rust_bridge_codegen ^
  --rust-input src/flutter_ffi.rs ^
  --dart-output flutter/lib/generated_bridge.dart ^
  --class-name Rustdesk

echo Done, exit: %errorlevel%
