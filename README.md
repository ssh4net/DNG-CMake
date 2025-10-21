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

The build system uses the following system libraries:
- **zlib** (ZIP compression) /or zlib-ng in zlib compatible mode/
- **libjpeg** (JPEG support)
- **libjxl** (JPEG-XL support)
- **libexpat** (XML parsing)
- **libbrotli** (Brotli compression for JPEG-XL)
- **libhwy** (Google Highway SIMD library for JPEG-XL)
- **Boost** (uuid) - optional, can use system Boost library
- **XMP SDK** (optional, can use system library /not tested/ - note that official XMP SDK differs from the XMP SDK included in DNG SDK archive)

### Platform Requirements

#### Windows (MSVC)
- Visual Studio 2022 or later
- CMake 3.16 or later
- Ninja build system (optional)

Supported configurations:
- CMake + MSVC
- CMake + Visual Studio 2022 Generator
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
vcpkg install zlib:x64-windows libjpeg-turbo:x64-windows libjxl:x64-windows expat:x64-windows boost-uuid:x64-windows
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
      ..
```

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

## CMake Options

The build system supports enabling/disabling features (tested configurations noted):

- `-DQMAKE_PROJECT=ON/OFF` - Build XMP support (tested: ON)
- `-DUSE_LIBJXL=ON/OFF` - Enable JPEG-XL support (tested: ON)
- `-DUSE_LIBJPEG=ON/OFF` - Enable JPEG support (tested: ON)
- `-DBUILD_DNG_VALIDATE=ON/OFF` - Build dng_validate tool (tested: ON)
- Additional options may be available - see CMakeLists.txt

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
  - `dng_jxl.patch` - JPEG-XL integration patch
- `dng_sdk/` - Adobe DNG SDK source (user-provided)
- `xmp/` - XMP SDK source (from DNG SDK archive)

## Notes

- This build system prioritizes system libraries over bundled SDK sources for better performance and security
- All necessary preprocessor definitions and include paths from original Visual Studio projects are preserved
- JPEG-XL and JPEG support are enabled by default
- XMP metadata support is fully integrated using the XMP SDK from DNG SDK archive
- System XMP SDK support is available but not tested (official XMP SDK has differences)
- System Boost library (uuid) can be used instead of bundled sources

## Testing Status

- **Tested platforms:** Windows (MSVC), Linux (Clang)
- **Tested build types:** Static libraries only
- **Tested features:** XMP, JPEG-XL, JPEG, dng_validate
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
