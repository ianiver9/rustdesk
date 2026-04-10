@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" arm64 > nul 2>&1
set PATH=C:\Users\i-i\.cargo\bin;C:\Users\i-i\.rustup\toolchains\stable-aarch64-pc-windows-msvc\bin;C:\Program Files\LLVM\bin;C:\local\deploy\flutter\bin;%PATH%

rem Flutter's CMake toolchain looks for VS via ProgramFiles(x86) -- set it explicitly
if not defined ProgramFiles(x86) (
    set "ProgramFiles(x86)=C:\Program Files (x86)"
)

cd /d C:\local\prj\RustDesk_arm64\repo\flutter

echo === Starting flutter build windows --release ===
flutter build windows --release
echo === Done, exit code: %errorlevel% ===
