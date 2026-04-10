@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" arm64 > nul 2>&1
rem Adjust REPO_DIR if you cloned to a different location
set REPO_DIR=C:\local\prj\RustDesk_arm64\repo

set PATH=%USERPROFILE%\.cargo\bin;%USERPROFILE%\.rustup\toolchains\stable-aarch64-pc-windows-msvc\bin;C:\Program Files\LLVM\bin;%PATH%

cd /d %REPO_DIR%\libs\virtual_display\dylib

set VCPKG_ROOT=C:\local\deploy\vcpkg
set VCPKG_INSTALLED_ROOT=%REPO_DIR%\vcpkg_installed
set VCPKGRS_TRIPLET=arm64-windows-static

cargo build --release --target aarch64-pc-windows-msvc
