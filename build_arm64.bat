@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" arm64
if errorlevel 1 (
    echo vcvarsall.bat failed
    exit /b 1
)

rem Adjust REPO_DIR if you cloned to a different location
set REPO_DIR=C:\local\prj\RustDesk_arm64\repo

set PATH=%USERPROFILE%\.cargo\bin;%USERPROFILE%\.rustup\toolchains\stable-aarch64-pc-windows-msvc\bin;C:\Program Files\LLVM\bin;%PATH%

cd /d %REPO_DIR%

set VCPKG_ROOT=C:\local\deploy\vcpkg
set VCPKG_INSTALLED_ROOT=%REPO_DIR%\vcpkg_installed
set VCPKGRS_TRIPLET=arm64-windows-static
set SODIUM_LIB_DIR=%REPO_DIR%\vcpkg_installed\arm64-windows-static\lib
set BINDGEN_EXTRA_CLANG_ARGS=

cargo build --release --target aarch64-pc-windows-msvc
