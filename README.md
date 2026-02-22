# DNG SDK CMake Build System

CMake build system for Adobe DNG SDK 1.7.1 with support for system libraries and cross-platform compilation.

## Overview

This CMake build system allows building Adobe DNG SDK 1.7.1 using system-provided libraries instead of the bundled sources that may be obsolete or inefficient. It prioritizes using modern system libraries for ZIP, JPEGXL, JPEG, and optionally Boost (uuid) and XMP.

## Prerequisites

### Adobe DNG SDK

Download Adobe DNG SDK 1.7.1 from Adobe:
[Digital Negative (DNG)](https://helpx.adobe.com/camera-raw/digital-negative.html)

Extract the SDK to the same folder as DNG-Cmake.

### System Libraries

The build system uses the following system libraries by default:
- **zlib** (ZIP compression) zlib or zlib-ng in zlib compatible mode
- **libjpeg** (JPEG support) jpeg or turbo-jpeg
- **libjxl** (JPEGXL support)
- **lcms2** (required by `libjxl_cms` for color transforms)
- **libexpat** (XML parsing)
- **libbrotli** (Brotli compression for JPEGXL)
- **libhwy** (Google Highway SIMD library for JPEGXL)
- **Boost** (uuid) - bundled in XMP SDK or optionally can use system Boost library
- **XMP SDK** (can use system library /not tested/ - note that official XMP SDK differs from the XMP SDK included in DNG SDK archive)

### Bundled Library Options

By default, the build system prioritizes system libraries for better performance and security. However, you can optionally use bundled versions:

- `DNG_BUNDLED_JPEG=OFF` (default) - Use system libjpeg
- `DNG_BUNDLED_JXL=OFF` (default) - Use system libjxl
- `XMP_USE_SYSTEM_ZLIB=ON` (default) - Use system zlib
- `XMP_USE_SYSTEM_BOOST=OFF` (default) - Use bundled Boost UUID headers

To use bundled libraries instead of system libraries:

```bash
cmake -DDNG_BUNDLED_JPEG=ON -DDNG_BUNDLED_JXL=ON -DXMP_USE_SYSTEM_ZLIB=OFF -DXMP_USE_SYSTEM_BOOST=ON ..
```

### Cache Variable Management

The build system preserves important CMake cache variables across reconfigurations:

- **`CMAKE_MSVC_RUNTIME_LIBRARY`** - Set to `MultiThreaded$<$<CONFIG:Debug>:Debug>` for static runtime linking
- **`CMAKE_DEBUG_POSTFIX`** - Set to `"d"` for debug library naming (e.g., `dng_sdkd.lib`)
- **`CMAKE_PREFIX_PATH`** - Preserved for system library search paths
- **`CMAKE_INSTALL_PREFIX`** - Defaults to `${CMAKE_SOURCE_DIR}/install`

These variables are cached and persist across `cmake` reconfigurations, ensuring consistent builds.

### Debug/Release Library Linking

The build system properly handles debug and release library linking using CMake generator expressions and imported targets with config-specific properties. This ensures that:

- **Debug builds** link only debug libraries (e.g., `libjpegd.lib`, `jxld.lib`)
- **Release builds** link only release libraries (e.g., `libjpeg.lib`, `jxl.lib`)
- **No mixing** of debug and release libraries in the same build
- **No duplicate linking** - libraries are linked only once through transitive dependencies

This prevents linker errors, runtime library mismatches, and ensures optimal performance for each build configuration.

#### How It Works

1. **`dng_sdk`** library links dependencies with `PUBLIC` linkage, making them available to consumers
2. **`dng_validate`** links only `dng_sdk` and gets all dependencies transitively
3. **Imported targets** use `IMPORTED_LOCATION_RELEASE` and `IMPORTED_LOCATION_DEBUG` properties
4. **CMake automatically selects** the correct library variant based on build configuration

### Platform Requirements

#### Windows (MSVC)
- Visual Studio 2017 or later
- CMake 3.16 or later
- Ninja build system (optional)

Supported configurations:
- CMake + MSVC
- CMake + Visual Studio 2017 Generator
- Ninja + MSVC

#### Linux
- CMake 3.16 or later
- Clang 20 or GCC (GCC not tested)
- Ninja build system (optional)

Supported configurations:
- Ninja + Clang
- Ninja + GCC (not tested)

## Installation of Dependencies

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install -y \
    clang-20 \
    cmake \
    ninja-build \
    build-essential \
    libjpeg-dev \
    libjxl-dev \
    liblcms2-dev \
    libexpat1-dev \
    zlib1g-dev \
    libbrotli-dev \
    libhwy-dev \
    libboost-dev \
    pkg-config
```

### Windows

Use vcpkg or manually install the required libraries:

```cmd
vcpkg install zlib:x64-windows libjpeg-turbo:x64-windows libjxl:x64-windows lcms2:x64-windows expat:x64-windows boost-uuid:x64-windows
```

## Building

### Linux with Clang + Ninja

1. Create a build directory:
```bash
mkdir build
cd build
```

2. Configure with Clang:
```bash
cmake -G Ninja \
      -DCMAKE_C_COMPILER=clang-20 \
      -DCMAKE_CXX_COMPILER=clang++-20 \
      -DCMAKE_BUILD_TYPE=Release \
      -DDNG_CLANG_STDLIB=default \
      -DCMAKE_PREFIX_PATH=/path/to/deps \
      ..
```

**ABI note (Clang on Linux):** pick `DNG_CLANG_STDLIB` to match your dependency ABI:
- `default` (recommended): use Clang toolchain default (typically `libstdc++` on Linux)
- `libstdc++`: force GNU C++ standard library
- `libc++`: force LLVM C++ standard library

Examples:
- `-DDNG_CLANG_STDLIB=libstdc++ -DCMAKE_PREFIX_PATH=/mnt/e/UBSTD/Release`
- `-DDNG_CLANG_STDLIB=libc++ -DCMAKE_PREFIX_PATH=/mnt/e/UBc/Release`

3. Build:
```bash
ninja
```

### Windows with Visual Studio 2022

1. Create a build directory:
```cmd
mkdir build
cd build
```

2. Configure:
```cmd
cmake -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release ..
```

3. Build:
```cmd
cmake --build . --config Release
```

### Windows with Ninja + MSVC

1. Open Visual Studio Developer Command Prompt
2. Create a build directory:
```cmd
mkdir build
cd build
```

3. Configure:
```cmd
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
```

4. Build:
```cmd
ninja
```

## Building Documentation

To generate API documentation with Doxygen:

### Prerequisites

Install Doxygen:
- **Ubuntu/Debian**: `sudo apt install doxygen graphviz`
- **Windows**: Download from [doxygen.nl/download.html](https://www.doxygen.nl/download.html)
- **macOS**: `brew install doxygen graphviz`

Note: Graphviz (dot) is optional but recommended for generating class diagrams.

### Generate Documentation

1. Configure with documentation enabled:
```bash
cmake -DBUILD_DOCUMENTATION=ON ..
```

2. Build (documentation is built automatically):
```bash
# Standard build - documentation is generated automatically
cmake --build .

# Or explicitly build just documentation
cmake --build . --target docs
```

3. Install (documentation is installed automatically):
```bash
# Standard install - documentation is included
cmake --install .
```

The generated HTML documentation will be located in:
- Build directory: `build/docs/dng_sdk/html/` and `build/docs/xmp/html/`
- After installation (Unix): `<install-prefix>/share/doc/dng_sdk/` and `<install-prefix>/share/doc/xmp/`
- After installation (Windows): `<install-prefix>/doc/dng_sdk/` and `<install-prefix>/doc/xmp/`

**Note:** When `BUILD_DOCUMENTATION=ON`, documentation is generated during the normal build process and installed with the standard install target. You don't need to use separate commands or components.

## CMake Options

### Core Build Options

- `-DBUILD_DNG_VALIDATE=ON/OFF` - Build dng_validate tool (default: ON)
- `-DDNG_THREAD_SAFE=ON/OFF` - Enable thread-safe DNG SDK (default: ON)
- `-DDNG_WITH_JPEG=ON/OFF` - Enable JPEG support via libjpeg (default: ON)
- `-DDNG_WITH_JXL=ON/OFF` - Enable JPEG-XL support via libjxl (default: ON)
- `-DDNG_WITH_XMP=ON/OFF` - Enable XMP metadata support (default: ON)

### Debug and Diagnostic Options

- `-DDNG_REPORT_ERRORS=ON/OFF` - Enable error reporting (default: ON)
- `-DDNG_VALIDATE=ON/OFF` - Enable validation checks (default: OFF)
- `-DDNG_DEBUG_PIXEL_TYPE=ON/OFF` - Enable pixel type debugging (default: OFF)
- `-DDNG_LOG_UPDATE_METADATA=ON/OFF` - Log metadata updates (default: OFF)
- `-DDNG_OPT_GETBITS_MATH=ON/OFF` - Use optimized bit extraction (default: OFF)

### Documentation Generation

- `-DBUILD_DOCUMENTATION=ON/OFF` - Build API documentation with Doxygen (default: OFF)

When enabled, requires Doxygen to be installed on your system. Generates HTML documentation for both DNG SDK and XMP Toolkit APIs.

### Advanced Options

- `-DXMP_USE_SYSTEM_BOOST=ON/OFF` - Use system Boost UUID instead of vendored (default: OFF)
- `-DXMP_ROOT=<path>` - Path to XMP toolkit root if not in repo
- `-DCMAKE_PREFIX_PATH=<paths>` - Semicolon-separated library search paths
- `-DDNG_CLANG_STDLIB=default|libstdc++|libc++` - Clang C++ standard library selection on non-MSVC Clang builds (default: `default`)
- `-DDNG_TARGET_PLATFORM=auto|windows|macos|ios|linux|android|web` - Resolved platform macros exported to consumers (default: `auto`)

## Output

The build produces static libraries (tested):
- `libdng_sdk.a` / `dng_sdk.lib` - Static DNG SDK library
- `libXMPCoreStatic.a` / `XMPCoreStatic.lib` - XMP Core static library  
- `libXMPFilesStatic.a` / `XMPFilesStatic.lib` - XMP Files static library
- `dng_validate` / `dng_validate.exe` - Command-line DNG validation tool

**Note:** Only static builds have been tested on Windows and Linux. Shared library builds are not currently supported.

## Project Structure

- `CMakeLists.txt` - Root CMake configuration
- `cmake/` - CMake patches and helper files
  - `dng_jxl.patch` - JPEGXL integration patch
- `dng_sdk/` - Adobe DNG SDK source (user-provided)
- `xmp/` - XMP SDK source (from DNG SDK archive)

## Notes

- This build system prioritizes system libraries over bundled SDK sources for better performance and security
- All necessary preprocessor definitions and include paths from original Visual Studio projects are preserved
- JPEGXL and JPEG support are enabled by default
- XMP metadata support is fully integrated using the XMP SDK from DNG SDK archive
- System XMP SDK support is available but not tested (official XMP SDK has differences)
- System Boost library (uuid) can be used instead of bundled sources

## Testing Status

- **Tested platforms:** Windows (MSVC), Linux (Clang)
- **Tested build types:** Static libraries only
- **Tested features:** XMP, JPEGXL, JPEG, dng_validate
- **Not tested:** GCC compilation, dynamic libraries, system XMP SDK or Boost

## Troubleshooting

### Missing Dependencies

Ensure all required development packages are installed. The build system will attempt to find system libraries automatically.

### WSL2 Users

Make sure you have the latest distribution and all packages are up to date:
```bash
sudo apt update && sudo apt upgrade
```

### vcpkg Integration

If using vcpkg on Windows, specify the toolchain file:
```cmd
cmake -DCMAKE_TOOLCHAIN_FILE=path/to/vcpkg/scripts/buildsystems/vcpkg.cmake ..
```
