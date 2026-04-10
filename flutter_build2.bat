@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" arm64 > nul 2>&1
rem Adjust REPO_DIR and FLUTTER_DIR if installed elsewhere
set REPO_DIR=C:\local\prj\RustDesk_arm64\repo
set FLUTTER_DIR=C:\local\deploy\flutter

set PATH=%USERPROFILE%\.cargo\bin;%USERPROFILE%\.rustup\toolchains\stable-aarch64-pc-windows-msvc\bin;C:\Program Files\LLVM\bin;%FLUTTER_DIR%\bin;%PATH%

rem Flutter's CMake toolchain looks for VS via ProgramFiles(x86) -- set it explicitly
if not defined ProgramFiles(x86) (
    set "ProgramFiles(x86)=C:\Program Files (x86)"
)

cd /d %REPO_DIR%\flutter

echo === Starting flutter build windows --release ===
flutter build windows --release
echo === Done, exit code: %errorlevel% ===
