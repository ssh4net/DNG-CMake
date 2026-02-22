# Installation and Usage Guide

This document explains how to install and use the dng_sdk package in downstream projects.

## Build and Install

### Single-Config Generators (Ninja, Unix Makefiles)

```bash
# Configure
mkdir build && cd build
cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      ..

# Build
ninja

# Install (may need sudo)
sudo ninja install
```

### Multi-Config Generators (Visual Studio, Xcode)

```bash
# Configure (no CMAKE_BUILD_TYPE needed)
mkdir build && cd build
cmake -G "Visual Studio 17 2022" \
      -A x64 \
      -DCMAKE_INSTALL_PREFIX="C:/Program Files/dng_sdk" \
      ..

# Build both Debug and Release
cmake --build . --config Debug
cmake --build . --config Release

# Install both configurations
cmake --install . --config Debug
cmake --install . --config Release
```

**Important:** With multi-config generators (Visual Studio, Xcode):
- Do NOT set `CMAKE_BUILD_TYPE` - it's ignored
- Build and install each configuration separately
- CMake will install config-specific files: `dng_sdk-targets-debug.cmake` and `dng_sdk-targets-release.cmake`

## Installed Files Structure

After installation, files are placed as follows:

```
<prefix>/
├── bin/
│   ├── dng_validate[.exe]           # Release executable
│   └── dng_validated[.exe]          # Debug executable (with CMAKE_DEBUG_POSTFIX)
├── lib/
│   ├── libdng_sdk.a / dng_sdk.lib   # Release library
│   ├── libdng_sdkd.a / dng_sdkd.lib # Debug library
│   ├── libXMPCoreStatic.a           # Release
│   ├── libXMPCoreStaticd.a          # Debug
│   ├── libXMPFilesStatic.a          # Release
│   ├── libXMPFilesStaticd.a         # Debug
│   ├── cmake/
│   │   ├── dng_sdk/
│   │   │   ├── dng_sdk-config.cmake
│   │   │   ├── dng_sdk-config-version.cmake
│   │   │   ├── dng_sdk-targets.cmake
│   │   │   ├── dng_sdk-targets-debug.cmake      # If Debug was installed
│   │   │   └── dng_sdk-targets-release.cmake    # If Release was installed
│   │   └── XMPToolkit/
│   │       ├── XMPToolkit-config.cmake
│   │       ├── XMPToolkit-config-version.cmake
│   │       ├── XMPToolkit-targets.cmake
│   │       ├── XMPToolkit-targets-debug.cmake
│   │       └── XMPToolkit-targets-release.cmake
│   └── pkgconfig/
│       ├── dng_sdk.pc
│       ├── XMPCoreStatic.pc
│       ├── XMPFilesStatic.pc
│       └── XMPToolkit.pc
├── include/
│   ├── dng_sdk/
│   │   └── *.h                       # DNG SDK headers
│   └── xmp/
│       └── *.h, *.hpp                # XMP headers (no .cpp files)
```

## Using in CMake Projects

### Method 1: find_package() (Recommended)

```cmake
cmake_minimum_required(VERSION 3.16)
project(my_application)

# Find the installed package
find_package(dng_sdk 1.7 REQUIRED)

# Or find XMP separately if needed
# find_package(XMPToolkit 1.7 REQUIRED)

# Create your executable
add_executable(my_app main.cpp)

# Link against dng_sdk - includes everything you need
target_link_libraries(my_app PRIVATE dng_sdk::dng_sdk)

# Include directories are automatically added
# CMake will automatically select the right library (Debug/Release) based on your build type
```

### How Multi-Config Works with find_package()

When you use `find_package(dng_sdk)`, CMake:

1. Loads `dng_sdk-targets.cmake` which includes the config-specific file
2. For Visual Studio/Xcode (multi-config):
   - If building in Debug mode → links to `dng_sdkd.lib`
   - If building in Release mode → links to `dng_sdk.lib`
3. For Ninja/Makefiles (single-config):
   - Links to the library matching your `CMAKE_BUILD_TYPE`
4. If the requested configuration wasn't installed, CMake will fall back to another available configuration

### Build Your Project

**Single-Config (Ninja, Makefiles):**
```bash
mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH=/usr/local ..
ninja
```

**Multi-Config (Visual Studio):**
```bash
mkdir build && cd build
cmake -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="C:/Program Files/dng_sdk" ..
cmake --build . --config Debug
cmake --build . --config Release
```

## Using with pkg-config

```bash
# Set PKG_CONFIG_PATH if needed
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

# Get compiler flags
pkg-config --cflags dng_sdk
# Output: -I/usr/local/include/dng_sdk -DqDNGUseLibJPEG=1 -DqDNGUseLibJXL=1 ...

# Get linker flags
pkg-config --libs dng_sdk
# Output: -L/usr/local/lib -ldng_sdk -pthread ...

# Use in Makefile
CFLAGS = $(shell pkg-config --cflags dng_sdk)
LDFLAGS = $(shell pkg-config --libs dng_sdk)
```

**Note:** pkg-config doesn't distinguish between Debug/Release builds - it provides flags for the default installation.

## Using with CMake FetchContent

```cmake
include(FetchContent)

FetchContent_Declare(
    dng_sdk
    GIT_REPOSITORY https://github.com/your-repo/dng_sdk_cmake.git
    GIT_TAG v1.7.1
)

FetchContent_MakeAvailable(dng_sdk)

add_executable(my_app main.cpp)
target_link_libraries(my_app PRIVATE dng_sdk::dng_sdk)
```

## Troubleshooting

### "Could not find dng_sdk"

```bash
# Make sure CMAKE_PREFIX_PATH includes the install location
cmake -DCMAKE_PREFIX_PATH="/usr/local;/opt/local" ..
```

### Wrong Configuration Selected

CMake selects configurations in this order:
1. Exact match to your build type
2. Release (if available)
3. Any available configuration

To debug:
```cmake
find_package(dng_sdk REQUIRED)
get_target_property(DNG_LIB dng_sdk::dng_sdk IMPORTED_LOCATION)
message(STATUS "Using dng_sdk library: ${DNG_LIB}")
```

### Multi-Config: Only One Configuration Available

If you only installed Release but are building Debug:
```
CMake Warning: The imported target "dng_sdk::dng_sdk" references the file
  "/usr/local/lib/libdng_sdk.a"
but this file does not exist for configuration "DEBUG".
```

**Solution:** Install both configurations:
```bash
cmake --install . --config Debug
cmake --install . --config Release
```

## Advanced: Using Only XMP Toolkit

```cmake
# Find only XMP, not the full DNG SDK
find_package(XMPToolkit 1.7 REQUIRED)

add_executable(xmp_app main.cpp)
target_link_libraries(xmp_app PRIVATE
    XMP::XMPCoreStatic
    XMP::XMPFilesStatic
)
```

## Platform-Specific Notes

### Windows
- Use forward slashes in paths: `C:/Program Files/dng_sdk`
- Or use escaped backslashes: `C:\\Program Files\\dng_sdk`
- Visual Studio automatically handles Debug/Release configurations

### Linux
- Default install prefix: `/usr/local`
- May need sudo for system-wide installation
- Or use user prefix: `-DCMAKE_INSTALL_PREFIX=$HOME/.local`

### macOS
- Use Xcode generator or Ninja
- May need to set deployment target: `-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15`
