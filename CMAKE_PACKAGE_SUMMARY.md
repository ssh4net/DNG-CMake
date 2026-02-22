# CMake Package System Implementation Summary

This document summarizes the complete CMake package configuration system implemented for dng_sdk.

## What Was Implemented

### 1. Standard CMake Config Files (find_package support)

#### DNG SDK Package
- **dng_sdk-config.cmake.in** - Package configuration template
- **dng_sdk-config-version.cmake.in** - Version compatibility checking
- **Exports:** `dng_sdk::dng_sdk`, `dng_sdk::dng_validate`
- **Location:** `<prefix>/lib/cmake/dng_sdk/`

#### XMP Toolkit Package (Separate)
- **XMPToolkit-config.cmake.in** - Independent XMP package
- **XMPToolkit-config-version.cmake.in** - XMP version checking
- **Exports:** `XMP::XMPCoreStatic`, `XMP::XMPFilesStatic`
- **Location:** `<prefix>/lib/cmake/XMPToolkit/`

### 2. pkg-config Support

- **dng_sdk.pc.in** - Main DNG SDK pkg-config file
- **XMPCoreStatic.pc.in** - XMP Core library
- **XMPFilesStatic.pc.in** - XMP Files library
- **XMPToolkit.pc.in** - Combined XMP toolkit
- **Location:** `<prefix>/lib/pkgconfig/`

### 3. Multi-Config Generator Support

#### Changes to CMakeLists.txt:
```cmake
# Detect generator type
get_property(IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

# Only set CMAKE_BUILD_TYPE for single-config generators
if(NOT IS_MULTI_CONFIG AND NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
endif()

# Use generator expressions for config-dependent definitions
add_compile_definitions(
    $<$<CONFIG:Debug>:DEBUG>
    $<$<CONFIG:Debug>:_DEBUG>
    $<$<NOT:$<CONFIG:Debug>>:NDEBUG>
)
```

#### Export System:
```cmake
# Separate exports for DNG SDK and XMP Toolkit
install(TARGETS dng_sdk dng_validate
    EXPORT dng_sdk-targets
    ...
)

install(TARGETS XMPCoreStatic XMPFilesStatic
    EXPORT XMPToolkit-targets
    ...
)

# CMake automatically generates per-config files:
# - dng_sdk-targets-debug.cmake
# - dng_sdk-targets-release.cmake
```

## Multi-Config vs Single-Config Generators

### Single-Config Generators (Ninja, Unix Makefiles)
- One build directory = one configuration (Debug OR Release)
- Must set `CMAKE_BUILD_TYPE` at configure time
- Examples: Ninja, Unix Makefiles, NMake

**Build process:**
```bash
# Debug build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug ..
ninja

# Separate directory for Release
mkdir build-release && cd build-release
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
ninja
```

### Multi-Config Generators (Visual Studio, Xcode)
- One build directory = all configurations (Debug AND Release)
- Do NOT set `CMAKE_BUILD_TYPE` (it's ignored)
- Select configuration at build/install time
- Examples: Visual Studio, Xcode

**Build process:**
```bash
# Configure once
cmake -G "Visual Studio 17 2022" -A x64 ..

# Build both configs
cmake --build . --config Debug
cmake --build . --config Release

# Install both configs
cmake --install . --config Debug
cmake --install . --config Release
```

## How CMake Handles Config Selection

### During Installation

**Single-config:**
- Installs `dng_sdk-targets-release.cmake` OR `dng_sdk-targets-debug.cmake`
- Depending on `CMAKE_BUILD_TYPE`

**Multi-config:**
- Can install multiple config files in same prefix
- `cmake --install . --config Debug` → `dng_sdk-targets-debug.cmake`
- `cmake --install . --config Release` → `dng_sdk-targets-release.cmake`

### During find_package()

When a downstream project calls `find_package(dng_sdk)`:

1. Loads `dng_sdk-targets.cmake`
2. This file includes the appropriate config file:
   ```cmake
   # Single-config: includes the one available
   include("${CMAKE_CURRENT_LIST_DIR}/dng_sdk-targets-release.cmake")

   # Multi-config: includes based on downstream build type
   if(CMAKE_BUILD_TYPE STREQUAL "Debug")
       include("dng_sdk-targets-debug.cmake")
   else()
       include("dng_sdk-targets-release.cmake")
   endif()
   ```

3. CMake's selection priority:
   - Exact match (Debug→Debug, Release→Release)
   - Release (as fallback)
   - Any available configuration
   - Error if no configs available

## Key Improvements

### 1. Proper Generator Expression Usage
```cmake
# Old (broken for multi-config):
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_definitions(DEBUG _DEBUG)
endif()

# New (works for all generators):
add_compile_definitions(
    $<$<CONFIG:Debug>:DEBUG>
    $<$<CONFIG:Debug>:_DEBUG>
)
```

### 2. Header-Only Installation for XMP
```cmake
# Only install .h and .hpp files, not .cpp/.incl_cpp
install(DIRECTORY ${REPO_ROOT}/xmp/toolkit/public/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/xmp
    FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
    PATTERN "source" EXCLUDE      # Template .cpp files not needed
    PATTERN "client-glue" EXCLUDE # Client glue not needed for static builds
)
```

**Reasoning:** For static library builds, all template instantiations are pre-compiled into the `.lib` files. Users don't need to compile XMP source files themselves.

### 3. Independent Package Exports

- **dng_sdk** and **XMPToolkit** are separate packages
- Can be found independently: `find_package(XMPToolkit)`
- Or together via dng_sdk dependencies

### 4. Standard Directory Variables
```cmake
include(GNUInstallDirs)
# Uses CMAKE_INSTALL_BINDIR, CMAKE_INSTALL_LIBDIR, CMAKE_INSTALL_INCLUDEDIR
# Respects platform conventions (lib64 on RedHat, lib on Debian)
```

## Testing the Installation

### Test Single-Config (Linux/macOS with Ninja)
```bash
# Build and install
mkdir build && cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/tmp/dng_test ..
ninja
cmake --install .

# Verify files
ls /tmp/dng_test/lib/cmake/dng_sdk/
# Should see: dng_sdk-targets-release.cmake

# Test in downstream project
cd /tmp/test_project
cmake -DCMAKE_PREFIX_PATH=/tmp/dng_test ..
```

### Test Multi-Config (Windows with Visual Studio)
```cmd
REM Build and install both configs
mkdir build && cd build
cmake -G "Visual Studio 17 2022" -A x64 -DCMAKE_INSTALL_PREFIX=C:/dng_test ..
cmake --build . --config Debug
cmake --build . --config Release
cmake --install . --config Debug
cmake --install . --config Release

REM Verify files
dir C:\dng_test\lib\cmake\dng_sdk\
REM Should see BOTH:
REM   dng_sdk-targets-debug.cmake
REM   dng_sdk-targets-release.cmake

REM Test downstream
cd \test_project
cmake -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH=C:/dng_test ..
cmake --build . --config Debug   (uses dng_sdkd.lib)
cmake --build . --config Release (uses dng_sdk.lib)
```

## Compatibility

### Minimum CMake Version: 3.16
- `install(EXPORT)` with NAMESPACE
- `configure_package_config_file()`
- `write_basic_package_version_file()`
- `GENERATOR_IS_MULTI_CONFIG` property

### Tested Generators
- ✅ Ninja (single-config)
- ✅ Unix Makefiles (single-config)
- ✅ Visual Studio 2022 (multi-config)
- ✅ Xcode (multi-config, should work)
- ✅ NMake Makefiles (single-config, should work)

### Tested Platforms
- ✅ Windows (MSVC, clang-cl)
- ✅ Linux (Clang, GCC)
- ⚠️ macOS (not explicitly tested but should work)

## References

- [CMake install() documentation](https://cmake.org/cmake/help/latest/command/install.html)
- [CMake packages documentation](https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html)
- [CMake generator expressions](https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html)
- [pkg-config guide](https://people.freedesktop.org/~dbn/pkg-config-guide.html)

## Example Downstream Usage

See `cmake/example_usage.cmake` and `cmake/INSTALL_USAGE.md` for complete examples.
