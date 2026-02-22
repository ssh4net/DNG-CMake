# CMake 4.1.2 Build Issues and Workarounds

## Issue: Ninja Generator Error on Windows

### Error Message
```
ninja: error: CMakeFiles\rules.ninja:23: expected newline, got lexing error
rule CXX_COMPILER__XMPCoreStatic_unscanned_Debug,Release
                                                ^ near here
```

### Root Cause
CMake 4.1.2 has stricter parsing for Ninja build files. The error occurs when using:
- **Generator:** Ninja or Ninja Multi-Config
- **Compiler:** MSVC
- **Platform:** Windows

The issue is that CMake 4.1.2 is generating invalid Ninja rule names with multiple configurations.

## Workarounds

### Option 1: Use Visual Studio Generator (Recommended for Windows)

Instead of Ninja, use the native Visual Studio generator:

```cmd
mkdir build
cd build
cmake -G "Visual Studio 17 2022" -A x64 ..
cmake --build . --config Release
```

**Advantages:**
- Native MSVC integration
- Better IDE support
- Avoids Ninja parsing issues
- Fully tested with CMake 4.1.2

### Option 2: Downgrade to CMake 3.31

If you must use Ninja on Windows:

```cmd
# Download CMake 3.31 from https://cmake.org/download/
# Install and use it instead
cmake --version  # Should show 3.31.x

mkdir build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
ninja
```

### Option 3: Use Unix Makefiles Generator

```cmd
mkdir build
cd build
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --config Release
```

### Option 4: Wait for CMake 4.1.3 Patch

This appears to be a bug in CMake 4.1.2's Ninja generator. It may be fixed in the next patch release.

You can track the issue at:
- CMake issue tracker: https://gitlab.kitware.com/cmake/cmake/-/issues
- CMake discourse: https://discourse.cmake.org/

## Linux/macOS Users

This issue only affects Windows + Ninja + MSVC. Linux and macOS users can continue using Ninja without problems:

```bash
cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
ninja
```

## If You're Using CMake 3.x

If the error persists with CMake 3.x, try cleaning the build directory:

```cmd
rd /s /q build
mkdir build
cd build
cmake -G "Visual Studio 17 2022" -A x64 ..
```

## Reporting the Bug

If you believe this is a CMake bug, please report it with:
1. CMake version: `cmake --version`
2. Generator used: `-G Ninja` or `-G "Ninja Multi-Config"`
3. Compiler: MSVC version
4. Full error output
5. Minimal reproducible example

Report at: https://gitlab.kitware.com/cmake/cmake/-/issues
