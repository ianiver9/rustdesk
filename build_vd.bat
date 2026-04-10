@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" arm64 > nul 2>&1
set PATH=C:\Users\i-i\.cargo\bin;C:\Users\i-i\.rustup\toolchains\stable-aarch64-pc-windows-msvc\bin;C:\Program Files\LLVM\bin;%PATH%

cd /d C:\local\prj\RustDesk_arm64\repo\libs\virtual_display\dylib

set VCPKG_ROOT=C:\local\deploy\vcpkg
set VCPKG_INSTALLED_ROOT=C:\local\prj\RustDesk_arm64\repo\vcpkg_installed
set VCPKGRS_TRIPLET=arm64-windows-static

cargo build --release --target aarch64-pc-windows-msvc
