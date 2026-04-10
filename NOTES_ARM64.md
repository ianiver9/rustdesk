# RustDesk ARM64 Windows — Build Notes

> **Last updated:** 2026-04-10  
> **Hardware:** Snapdragon X Elite / Windows 11 ARM64  
> **Status:** Rust backend ✅ complete · Flutter frontend ❌ blocked (Flutter toolchain limitation)

---

## Current Build Status

| Component | Status | Notes |
|-----------|--------|-------|
| Rust cargo build (`aarch64-pc-windows-msvc`) | ✅ | `rustdesk.exe`, `librustdesk.dll` produced |
| `dylib_virtual_display.dll` | ✅ | Built from `libs/virtual_display/dylib` |
| `generated_bridge.dart` | ❌ | `ffigen` runs as x64, can't load ARM64 `libclang.dll` |
| Flutter Windows build | ❌ | Flutter 3.41.6 produces `build/windows/x64/` on ARM64 hardware |
| Dart type errors | ❌ | Several files need null-safety updates for Dart 3.11 |

---

## Why Flutter is Blocked

Flutter 3.41.6 on Windows ARM64 still falls back to x64 build output (`build/windows/x64/`). The Flutter toolchain, Dart SDK, and `ffigen` helper all run as x64 processes under emulation. This means:

1. **`ffigen` (used by `flutter_rust_bridge_codegen`)** tries to load `libclang.dll`. The system has an ARM64 LLVM at `C:\Program Files\LLVM\bin\libclang.dll`. An x64 process cannot load an ARM64 DLL — Windows returns error 193 (`%1 is not a valid Win32 application`).

2. **`flutter build windows`** outputs to `build/windows/x64/runner/Release/`, not `arm64/`. The Flutter runner itself is x64.

3. **Mixed-arch DLL loading is forbidden by Windows.** An x64 Flutter runner cannot load the ARM64 `librustdesk.dll` at runtime, so even if both compile, the app would crash on launch.

**The fix requires Flutter to ship a native ARM64 Windows toolchain** (compiler, embedder, engine). Watch Flutter's Windows ARM64 tracking issue; it is expected in a future stable release (estimated 3.5 or later, as of 2026-04).

---

## Environment Requirements (to resume)

| Tool | Version / Location |
|------|--------------------|
| Rust | stable `aarch64-pc-windows-msvc` (≥ 1.91) |
| Visual Studio | 2022 Community, ARM64 build tools installed |
| LLVM | 22.x ARM64 at `C:\Program Files\LLVM` |
| vcpkg | `C:\local\deploy\vcpkg` |
| Flutter | When ARM64 Windows is supported (check flutter.dev) |
| `flutter_rust_bridge_codegen` | v1.80.1 (`cargo install flutter_rust_bridge_codegen --version 1.80.1`) |

vcpkg packages are pre-built in `vcpkg_installed\arm64-windows-static\` — no need to rebuild.

---

## Changes Made to This Fork

### `libs/scrap/build.rs`
**Root cause:** bindgen 0.65.1 on Windows ARM64 sees only forward-declarations of `vpx_codec_enc_cfg`, `vpx_codec_dec_cfg`, `aom_codec_enc_cfg`, `aom_codec_dec_cfg` from codec.h pointer fields and never updates to the full definitions found in encoder.h / decoder.h. It generates empty opaque structs `{ pub _address: u8 }`.

**Fix:** Post-process the generated `.rs` files after bindgen runs. Added:
- `get_msvc_include_paths()` — reads the MSVC `INCLUDE` env var set by `vcvarsall.bat arm64`; falls back to vswhere + Windows Kits autodiscovery
- ARM64 clang args: `--target=aarch64-pc-windows-msvc` + all MSVC include paths
- `patch_opaque_cfg_structs()` — dispatches to `patch_vpx_cfg_structs()` or `patch_aom_cfg_structs()` based on filename
- `patch_vpx_cfg_structs()` — replaces opaque `vpx_codec_enc_cfg` (60+ fields) and `vpx_codec_dec_cfg` (3 fields) with hand-written correct definitions matching `vpx_encoder.h` / `vpx_decoder.h`
- `patch_aom_cfg_structs()` — injects `cfg_options_t` (36 `c_uint` fields; excluded from allowlist so bindgen never generates it), then replaces opaque `aom_codec_enc_cfg` (~50 fields) and `aom_codec_dec_cfg` (4 fields) with correct definitions matching `aom_encoder.h` / `aom_decoder.h`

### `vcpkg.json`
- Excluded `ffmpeg` on ARM64 Windows (no hwcodec in initial build)
- Excluded `nvcodec`, `amf`, `qsv` hwcodec features (x86/x64 only)
- Added `libsodium` dependency
- Excluded `mfx-dispatch` on ARM64

### `build.py`
- Changed `flutter_build_dir` to `build/windows/arm64/runner/Release/` (anticipating future Flutter ARM64 support)
- **NOTE:** This path does not exist yet. Flutter 3.41.6 still builds to `x64`. Update this when Flutter ARM64 Windows is confirmed working.

### `build_arm64.bat` (new file)
Reproducible one-shot build script for the Rust backend:
```bat
call "...vcvarsall.bat" arm64
set PATH=C:\Users\i-i\.cargo\bin;C:\Users\i-i\.rustup\toolchains\stable-aarch64-pc-windows-msvc\bin;C:\Program Files\LLVM\bin;%PATH%
set VCPKG_ROOT=C:\local\deploy\vcpkg
set VCPKG_INSTALLED_ROOT=C:\local\prj\RustDesk_arm64\repo\vcpkg_installed
set VCPKGRS_TRIPLET=arm64-windows-static
set SODIUM_LIB_DIR=...\vcpkg_installed\arm64-windows-static\lib
cargo build --release --target aarch64-pc-windows-msvc
```

### `build_vd.bat` (new file)
Same environment, runs from `libs/virtual_display/dylib` to build the virtual display driver.

### `flutter_build2.bat` (new file)
Flutter build script with ARM64 environment and `ProgramFiles(x86)` workaround:
```bat
call vcvarsall.bat arm64
if not defined ProgramFiles(x86) set "ProgramFiles(x86)=C:\Program Files (x86)"
flutter build windows --release
```

### `gen_bridge.bat` (new file)
Generates `flutter/lib/generated_bridge.dart` from Rust FFI source:
```bat
flutter_rust_bridge_codegen \
  --rust-input src/flutter_ffi.rs \
  --dart-output flutter/lib/generated_bridge.dart \
  --class-name Rustdesk
```
**Currently blocked:** `ffigen` runs as x64, cannot load ARM64 `libclang.dll`. Will work once Flutter ships x64 LLVM support or native ARM64 Dart.

---

## Fix NOT in This Repo (must re-apply)

The `magnum-opus` crate's `build.rs` hardcodes `x86_64-windows-static` as the vcpkg triplet. This file is in cargo's git cache, not in this repo:

```
C:\Users\i-i\.cargo\git\checkouts\magnum-opus-<hash>\<rev>\build.rs
```

**Re-apply this fix when resuming:**
1. Find the path: `cargo metadata --manifest-path Cargo.toml | python -c "import json,sys; [print(p['manifest_path']) for p in json.load(sys.stdin)['packages'] if p['name']=='magnum-opus']"`
2. In `build.rs`, find the line that hardcodes `x86_64-windows-static` and replace with:
   ```rust
   format!("{}-windows-static", target_arch)
   ```
3. Also add support for `VCPKG_INSTALLED_ROOT` env var (used by our build setup).

Or: contribute the fix upstream to `magnum-opus`.

---

## Dart Errors to Fix (when resuming Flutter work)

After generating `generated_bridge.dart`, these files need edits for Dart 3.11 compatibility:

- **`flutter/lib/desktop/pages/desktop_setting_page.dart`** — `Future<Null> Function(String)?` assigned where `dynamic Function(dynamic)?` expected
- **`flutter/lib/desktop/widgets/remote_toolbar.dart`** — same pattern
- **`flutter/lib/common/widgets/toolbar.dart`** — same pattern  
- **`flutter/lib/common/widgets/dialog.dart`** — same pattern
- **`flutter/lib/models/native_model.dart`** — `RustdeskImpl` not found (comes from `generated_bridge.dart`, which must be generated first)

General fix: `Future<Null>` → `Future<void>` and review null-safety assignments.

---

## Resume Checklist

When Flutter ARM64 Windows support arrives:

1. **Check Flutter release notes** for "Windows ARM64" support
2. `flutter upgrade` to new version
3. **Re-apply magnum-opus fix** (see above)
4. **Delete scrap build cache** to force bindgen re-run:
   ```
   del /s /q target\aarch64-pc-windows-msvc\release\build\scrap-*
   del /s /q target\aarch64-pc-windows-msvc\release\.fingerprint\scrap-*
   ```
5. **Generate bridge:** run `gen_bridge.bat` (should work if ARM64 Dart / x64-compatible libclang is available)
6. **Fix Dart type errors** listed above
7. **Run Flutter build:** `flutter_build2.bat`
8. **Test:** copy `librustdesk.dll` and `dylib_virtual_display.dll` alongside the Flutter runner

---

## Build Artifacts Location

```
repo\target\aarch64-pc-windows-msvc\release\
    rustdesk.exe           (22 MB)
    librustdesk.dll
    
repo\libs\virtual_display\dylib\target\aarch64-pc-windows-msvc\release\
    dylib_virtual_display.dll
```

These are in `.gitignore` and not committed. Rebuild with `build_arm64.bat`.
