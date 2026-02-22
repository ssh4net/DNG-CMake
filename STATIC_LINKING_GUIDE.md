# Static Linking and Transitive Dependencies Guide

## Overview

This document explains how the DNG SDK CMake package system handles transitive dependencies for static library builds.

## The Problem with Static Libraries

When you build a static library and link it into an application, the application **also** needs to link against all the dependencies that the static library uses. This is different from shared/dynamic libraries, where the dependencies are resolved at runtime.

### Example

If `libdng_sdk.a` was built with JPEG-XL support, it internally uses:
- `libjxl.a`
- `libjxl_threads.a`
- `libhwy.a` (Highway SIMD library)
- `libbrotlidec.a`, `libbrotlienc.a`, `libbrotlicommon.a` (Brotli compression)

When you link your application against `libdng_sdk.a`, you must **also** link against all these libraries, or you'll get linker errors like "undefined reference to jxl::...".

## How This Build System Solves It

### 1. PUBLIC Linkage in Library Targets

All dependencies are linked with `PUBLIC` linkage instead of `PRIVATE`:

```cmake
# cmake/dng_sdk.cmake
target_link_libraries(dng_sdk PUBLIC
    Threads::Threads
    jxl::jxl
    jxl::jxl_threads
    hwy::hwy
    brotli::brotlidec
    brotli::brotlienc
    brotli::brotlicommon
)
```

**What this does:**
- When you link against `dng_sdk`, CMake automatically adds all PUBLIC dependencies to your link command
- The dependency information is saved in the installed `dng_sdk-targets.cmake` file

### 2. find_dependency() in Config Files

The `dng_sdk-config.cmake.in` file uses `find_dependency()` to locate all required libraries:

```cmake
# Find JPEG-XL and dependencies
if(@DNG_WITH_JXL@)
    find_package(libjxl CONFIG QUIET)
    if(NOT libjxl_FOUND)
        # Fallback to PkgConfig
        pkg_check_modules(JXL REQUIRED libjxl)
        pkg_check_modules(HWY REQUIRED libhwy)
        # ... etc
    endif()
endif()
```

**What this does:**
- When a downstream project calls `find_package(dng_sdk)`, CMake automatically finds all dependencies
- Uses multiple strategies: CMake config files, pkg-config, or manual library finding
- Creates imported targets for all dependencies

### 3. Dependency Chain

```
Your Application
  └─> dng_sdk::dng_sdk
       ├─> Threads::Threads
       ├─> JPEG::JPEG (if DNG_WITH_JPEG=ON)
       ├─> XMP::XMPCoreStatic (if DNG_WITH_XMP=ON)
       │    ├─> EXPAT::EXPAT
       │    └─> ZLIB::ZLIB
       ├─> XMP::XMPFilesStatic (if DNG_WITH_XMP=ON)
       │    └─> XMP::XMPCoreStatic
       └─> jxl::jxl (if DNG_WITH_JXL=ON)
            ├─> jxl::jxl_threads
            ├─> hwy::hwy
            ├─> brotli::brotlidec
            ├─> brotli::brotlienc
            └─> brotli::brotlicommon
```

All of these dependencies are automatically resolved when you link against `dng_sdk::dng_sdk`.

## Usage in Downstream Projects

### Method 1: find_package() (Recommended)

```cmake
cmake_minimum_required(VERSION 3.16)
project(my_app)

# Find dng_sdk - this automatically finds ALL dependencies
find_package(dng_sdk 1.7 REQUIRED)

add_executable(my_app main.cpp)

# This ONE line links everything you need
target_link_libraries(my_app PRIVATE dng_sdk::dng_sdk)

# No need to manually link JPEG, JXL, brotli, highway, etc.
# CMake does it automatically!
```

### Method 2: pkg-config

```bash
# Get all compiler and linker flags including dependencies
CFLAGS=$(pkg-config --cflags dng_sdk)
LIBS=$(pkg-config --libs dng_sdk)

g++ main.cpp $CFLAGS $LIBS -o my_app
```

## What Gets Linked Automatically

When you `target_link_libraries(my_app PRIVATE dng_sdk::dng_sdk)`:

**Always linked:**
- `pthread` (Threads::Threads)

**If `DNG_WITH_JPEG=ON`:**
- `libjpeg`

**If `DNG_WITH_JXL=ON`:**
- `libjxl`
- `libjxl_threads`
- `libhwy`
- `libbrotlidec`
- `libbrotlienc`
- `libbrotlicommon`

**If `DNG_WITH_XMP=ON`:**
- `libXMPCoreStatic` (which links `libexpat` and `libz`)
- `libXMPFilesStatic` (which links `libXMPCoreStatic`)

## Troubleshooting

### Problem: "undefined reference to jxl::..."

**Cause:** You're linking against `libdng_sdk.a` manually without CMake's target system.

**Solution:** Use `find_package(dng_sdk)` and link against `dng_sdk::dng_sdk` target, not the raw library file.

### Problem: "Could not find JPEG" when using find_package(dng_sdk)

**Cause:** The JPEG library is not in CMake's search path.

**Solution:**
```cmake
# Option 1: Set CMAKE_PREFIX_PATH
cmake -DCMAKE_PREFIX_PATH="/path/to/jpeg;/path/to/other/libs" ..

# Option 2: Set specific package directories
cmake -DJPEG_ROOT=/path/to/jpeg ..

# Option 3: Install libraries to standard locations (/usr/local, etc.)
```

### Problem: Static vs Shared Library Mismatch

**Cause:** Trying to link static `libdng_sdk.a` with shared `libjxl.so`.

**Solution:** Ensure all dependencies match the link type:
- Static build: Use static versions of all dependencies (`.a`, `.lib`)
- Shared build: Use shared versions of all dependencies (`.so`, `.dll`)

## How to Check What Gets Linked

### In Your Build System

```cmake
find_package(dng_sdk REQUIRED)

# Print the target's link libraries
get_target_property(DNG_LINK_LIBS dng_sdk::dng_sdk INTERFACE_LINK_LIBRARIES)
message(STATUS "dng_sdk links to: ${DNG_LINK_LIBS}")
```

### After Building

```bash
# Linux: Check what's linked in your executable
ldd my_app

# macOS: Check dependencies
otool -L my_app

# Windows: Check DLL dependencies
dumpbin /dependents my_app.exe
```

## Advanced: Overriding Dependency Search

If CMake can't find a dependency automatically, you can help it:

```cmake
# Set hints for specific libraries
set(EXPAT_ROOT "/opt/expat")
set(ZLIB_ROOT "/usr/local")
set(JPEG_ROOT "/opt/libjpeg-turbo")

# Or use CMAKE_PREFIX_PATH for all
list(APPEND CMAKE_PREFIX_PATH
    "/opt/expat"
    "/usr/local"
    "/opt/libjpeg-turbo"
)

find_package(dng_sdk REQUIRED)
```

## Technical Details

### Exported Target Properties

The installed `dng_sdk-targets.cmake` contains:

```cmake
# Pseudo-code showing what's exported
add_library(dng_sdk::dng_sdk STATIC IMPORTED)
set_target_properties(dng_sdk::dng_sdk PROPERTIES
    IMPORTED_LOCATION "/usr/local/lib/libdng_sdk.a"
    INTERFACE_LINK_LIBRARIES "Threads::Threads;jxl::jxl;hwy::hwy;..."
    INTERFACE_INCLUDE_DIRECTORIES "/usr/local/include/dng_sdk"
)
```

The `INTERFACE_LINK_LIBRARIES` property contains all transitive dependencies.

### Config File Search Strategy

`dng_sdk-config.cmake` tries multiple methods to find each dependency:

1. **CMake Config** - `find_package(libjxl CONFIG)`
2. **pkg-config** - `pkg_check_modules(JXL libjxl)`
3. **Manual** - `find_library(JXL_LIBRARY NAMES jxl)`

This ensures maximum compatibility across different systems and installation methods.

## Best Practices

1. **Always use `find_package()`** instead of manually specifying library paths
2. **Link against imported targets** (`dng_sdk::dng_sdk`) not raw libraries
3. **Install all dependencies** before building projects that use dng_sdk
4. **Use the same build type** (Debug/Release) for all libraries
5. **Match static/shared** - don't mix static and shared libraries

## References

- CMake documentation: [Imported Targets](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#imported-targets)
- CMake documentation: [target_link_libraries()](https://cmake.org/cmake/help/latest/command/target_link_libraries.html)
- pkg-config guide: [Writing pkg-config files](https://people.freedesktop.org/~dbn/pkg-config-guide.html)
