@echo off
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" arm64
if errorlevel 1 (
    echo vcvarsall.bat failed
    exit /b 1
)

set PATH=C:\Users\i-i\.cargo\bin;C:\Users\i-i\.rustup\toolchains\stable-aarch64-pc-windows-msvc\bin;C:\Program Files\LLVM\bin;%PATH%

cd /d C:\local\prj\RustDesk_arm64\repo

set VCPKG_ROOT=C:\local\deploy\vcpkg
set VCPKG_INSTALLED_ROOT=C:\local\prj\RustDesk_arm64\repo\vcpkg_installed
set VCPKGRS_TRIPLET=arm64-windows-static
set SODIUM_LIB_DIR=C:\local\prj\RustDesk_arm64\repo\vcpkg_installed\arm64-windows-static\lib
set BINDGEN_EXTRA_CLANG_ARGS=

cargo build --release --target aarch64-pc-windows-msvc
