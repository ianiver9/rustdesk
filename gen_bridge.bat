@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" arm64 > nul 2>&1
rem Adjust REPO_DIR and FLUTTER_DIR if installed elsewhere
set REPO_DIR=C:\local\prj\RustDesk_arm64\repo
set FLUTTER_DIR=C:\local\deploy\flutter

set PATH=%USERPROFILE%\.cargo\bin;%USERPROFILE%\.rustup\toolchains\stable-aarch64-pc-windows-msvc\bin;C:\Program Files\LLVM\bin;%FLUTTER_DIR%\bin;%PATH%

cd /d %REPO_DIR%

echo === Generating flutter_rust_bridge bindings ===
flutter_rust_bridge_codegen ^
  --rust-input src/flutter_ffi.rs ^
  --dart-output flutter/lib/generated_bridge.dart ^
  --class-name Rustdesk

echo Done, exit: %errorlevel%
