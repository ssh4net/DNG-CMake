# Preprocessor Definitions Reference

This document lists all configurable preprocessor definitions that can be set at compile time for the DNG SDK and XMP Toolkit.

All DNG SDK conditional compilation macros begin with a lowercase 'q' prefix. XMP Toolkit macros use the `XMP_` prefix.

---

## DNG SDK Preprocessor Definitions

### Platform Identification

These are automatically detected but can be overridden:

| Definition | Default | Description |
|------------|---------|-------------|
| `qMacOS` | Auto-detected | 1 if compiling for macOS |
| `qWinOS` | Auto-detected | 1 if compiling for Windows |
| `qLinux` | Auto-detected | 1 if compiling for Linux |
| `qAndroid` | Auto-detected | 1 if compiling for Android |
| `qiPhone` | Auto-detected | 1 if compiling for iPhone/iOS |
| `qiPhoneSimulator` | Auto-detected | 1 if compiling for iOS Simulator |
| `qWinRT` | Auto-detected | 1 if compiling for Windows Runtime (UWP) |
| `qWeb` | Auto-detected | 1 if compiling for WebAssembly |

### Architecture and CPU

| Definition | Default | Description |
|------------|---------|-------------|
| `qDNG64Bit` | Auto-detected | 1 if target platform uses 64-bit addresses |
| `qARM` | Auto-detected | 1 if compiling for ARM architecture |
| `qARM64` | Auto-detected | 1 if compiling for ARM64 architecture |
| `qX86_64` | Auto-detected | 1 if compiling for x86-64 architecture |
| `qDNGBigEndian` | Auto-detected | 1 if target is big endian (e.g. PowerPC) |
| `qDNGLittleEndian` | Auto-detected | 1 if target is little endian (e.g. x86, ARM) |
| `qDNGAVXSupport` | `(qMacOS\|\|qWinOS) && qDNG64Bit && !qARM` | 1 to enable AVX/AVX2 optimizations |

### Build Configuration

| Definition | Default | Description |
|------------|---------|-------------|
| `qDNGDebug` | Auto from `_DEBUG`/`Debug` | 1 for debug builds with assertions and checks |
| `qDNGValidateTarget` | 0 | 1 if building the dng_validate tool |
| `qDNGValidate` | `qDNGValidateTarget` | 1 to enable DNG validation code |
| `qDNGPrintMessages` | `qDNGValidate` | 1 to use fprintf to stderr, 0 for platform-specific interrupts |

### Feature Flags

| Definition | Default | Description |
|------------|---------|-------------|
| `qDNGThreadSafe` | `qMacOS\|\|qWinOS` | 1 for thread-safe SDK with mutex support |
| `qDNGUseXMP` | 1 | 1 to enable XMP metadata support |
| `qDNGXMPFiles` | 1 | 1 to use XMPFiles for file I/O |
| `qDNGXMPDocOps` | `!qDNGValidateTarget` | 1 to use XMPDocOps for document operations |
| `qDNGUseLibJPEG` | `qDNGValidateTarget` | 1 to use libjpeg for lossy JPEG processing |
| `qDNGUseLibJXL` | 0 | 1 to enable JPEG-XL support (requires libjxl) |
| `qDNGBigImage` | `qDNGExperimental` | 1 to support large images (300000px, 10GP) vs (65000px, 512MP) |
| `qDNGExperimental` | 1 | 1 to enable experimental features |
| `qDNGSupportVC5` | 1 | 1 to support VC-5 codec |

### Threading and Synchronization

| Definition | Default | Description |
|------------|---------|-------------|
| `qDNGThreadSafe` | Auto | 1 to enable thread safety with mutexes |
| `qDNGUseConditionVariable` | Auto | 1 to use condition variables for thread synchronization |
| `qDNGThreadTestMutexLevels` | 0 | 1 to enable mutex level testing (debug feature) |
| `BIB_MULTI_THREAD` | Controlled by CMake | Set by `DNG_THREAD_SAFE` CMake option |

### Compiler and Toolchain

| Definition | Default | Description |
|------------|---------|-------------|
| `qDNGIntelCompiler` | Auto-detected | 1 if using Intel C++ Compiler |
| `qVisualC` | Auto-detected | 1 if using Microsoft Visual C++ |
| `qDNGUsingSanitizer` | 0 | 1 when using AddressSanitizer or other sanitizer tools |

### Debug and Diagnostics

| Definition | Default | Description |
|------------|---------|-------------|
| `qDNGDebug` | Auto | 1 for debug builds with assertions |
| `qDNGReportErrors` | Auto | 1 to enable error reporting |
| `qDNGValidate` | 0 | 1 to enable validation checks |
| `qDebugPixelType` | 0 | 1 to enable pixel type debugging |
| `qLogDNGUpdateMetadata` | 0 | 1 to log metadata update operations |
| `qOptGetBitsMath` | 0 | 1 to use optimized bit extraction math |

### Raw Format Support

| Definition | Default | Description |
|------------|---------|-------------|
| `qSupportCanon_sRAW` | Auto | 1 to support Canon sRAW/mRAW formats |
| `qSupportHasselblad_3FR` | Auto | 1 to support Hasselblad 3FR format |
| `qSupportSony_sRAW` | Auto | 1 to support Sony compressed ARW format |

### Advanced/Internal

| Definition | Default | Description |
|------------|---------|-------------|
| `qDNGUseCustomIntegralTypes` | 0 | 1 to use custom integer types instead of stdint.h |
| `qIsFauxPlatformBuild` | 0 | 1 for cross-platform simulation builds |
| `qIsFauxLinuxPlatformBuild` | 0 | 1 for Linux simulation on other platforms |
| `qIsFauxWebPlatformBuild` | 0 | 1 for WebAssembly simulation |
| `qXCodeRez` | Auto | 1 when building with Xcode Rez tool |

---

## XMP Toolkit Preprocessor Definitions

### Platform Environment (Required)

**Exactly ONE must be defined by the build system:**

| Definition | Description |
|------------|-------------|
| `MAC_ENV` | Building for macOS (desktop) |
| `WIN_ENV` | Building for Windows |
| `UNIX_ENV` | Building for Linux/Unix |
| `IOS_ENV` | Building for iOS (mobile) |
| `ANDROID_ENV` | Building for Android |
| `WEB_ENV` | Building for WebAssembly/Emscripten |

These are converted to internal XMP macros:
- `XMP_MacBuild` - Set to 1 when `MAC_ENV` is defined
- `XMP_WinBuild` - Set to 1 when `WIN_ENV` is defined
- `XMP_UNIXBuild` - Set to 1 when `UNIX_ENV` is defined
- `XMP_iOSBuild` - Set to 1 when `IOS_ENV` is defined
- `XMP_AndroidBuild` - Set to 1 when `ANDROID_ENV` is defined

### Build Type

| Definition | Default | Description |
|------------|---------|-------------|
| `XMP_StaticBuild` | CMake controlled | 1 for static library builds |
| `XMP_DynamicBuild` | CMake controlled | 1 for shared/dynamic library builds |
| `XMP_DebugBuild` | Auto from `DEBUG`/`NDEBUG` | 1 for debug builds |

### Library Configuration

| Definition | Default | Description |
|------------|---------|-------------|
| `BUILDING_XMPCORE_LIB` | Set during build | 1 when building XMPCore library |
| `BUILDING_XMPFILES_LIB` | Set during build | 1 when building XMPFiles library |
| `BUILDING_XMPCORE_AS_STATIC` | Set during build | 1 for static XMPCore |
| `BUILDING_XMPFILES_AS_STATIC` | Set during build | 1 for static XMPFiles |

### Feature Flags

| Definition | Default | Description |
|------------|---------|-------------|
| `ENABLE_CPP_DOM_MODEL` | 0 | 1 to enable C++ DOM model (new API) |
| `XMP_MARKER_EXTENSIBILITY_BACKWARD_COMPATIBILITY` | Optional | 1 for marker extensibility backward compatibility |
| `XMP_64` | Auto-detected | 1 for 64-bit builds |

### Debug and Diagnostics

| Definition | Default | Description |
|------------|---------|-------------|
| `XMP_DebugBuild` | Auto | 1 for debug builds |
| `XMP_TraceCoreCalls` | 0 | 1 to trace XMPCore API calls |
| `XMP_TraceFilesCalls` | 0 | 1 to trace XMPFiles API calls |

### XML Parser Configuration

| Definition | Description |
|------------|-------------|
| `XML_STATIC` | 1 for static Expat linking |
| `XML_POOR_ENTROPY` | Use poor entropy for XML parser |
| `HAVE_EXPAT_CONFIG_H` | 1 if expat_config.h is available |

### Namespace Configuration

| Definition | Description |
|------------|-------------|
| `XMP_COMPONENT_INT_NAMESPACE` | Internal namespace for XMP components |
| Set to `AdobeXMPCore_Int` for XMPCore |
| Set to `AdobeXMPFiles_Int` for XMPFiles |

### Windows-Specific

| Definition | Description |
|------------|-------------|
| `WIN_ENV` | Must be defined for Windows builds |
| `WIN_UNIVERSAL_ENV` | Define for Universal Windows Platform (UWP) |
| `XMP_UWP` | Set to 1 for UWP builds |
| `_CRT_SECURE_NO_WARNINGS` | Disable MSVC security warnings |
| `_SCL_SECURE_NO_WARNINGS` | Disable MSVC STL security warnings |
| `NOMINMAX` | Prevent Windows.h from defining min/max macros |
| `UNICODE` | Use Unicode character set |
| `_UNICODE` | Use Unicode character set (alternative) |

### Internal/Private

| Definition | Description |
|------------|-------------|
| `AdobePrivate` | 1 for Adobe internal builds (change history, etc.) |

---

## CMake Build Options

The CMake build system provides high-level options that automatically set the appropriate preprocessor definitions:

### DNG SDK Options

| CMake Option | Preprocessor Definitions Set |
|--------------|------------------------------|
| `-DDNG_THREAD_SAFE=ON` | `BIB_MULTI_THREAD=1`, `qDNGThreadSafe=1` |
| `-DDNG_WITH_JPEG=ON` | `qDNGUseLibJPEG=1` |
| `-DDNG_WITH_JXL=ON` | `qDNGUseLibJXL=1` |
| `-DDNG_WITH_XMP=ON` | `qDNGUseXMP=1` |
| `-DBUILD_DNG_VALIDATE=ON` | `qDNGValidateTarget=1` (for dng_validate executable) |
| `-DDNG_REPORT_ERRORS=ON` | `qDNGReportErrors=1` |
| `-DDNG_VALIDATE=ON` | `qDNGValidate=1` |
| `-DDNG_DEBUG_PIXEL_TYPE=ON` | `qDebugPixelType=1` |
| `-DDNG_LOG_UPDATE_METADATA=ON` | `qLogDNGUpdateMetadata=1` |
| `-DDNG_OPT_GETBITS_MATH=ON` | `qOptGetBitsMath=1` |
| `-DCMAKE_BUILD_TYPE=Debug` | `DEBUG`, `_DEBUG`, `qDNGDebug=1` |
| `-DCMAKE_BUILD_TYPE=Release` | `NDEBUG` |

### XMP Toolkit Options

The CMake build automatically sets:
- Platform: `WIN_ENV`, `MAC_ENV`, or `UNIX_ENV` based on target
- `XMP_StaticBuild=1` (only static builds supported)
- `BUILDING_XMPCORE_LIB=1` / `BUILDING_XMPFILES_LIB=1` as appropriate
- `XMP_COMPONENT_INT_NAMESPACE` correctly for each component

---

## Usage Examples

### Example 1: Custom Build with JXL Support

```cmake
cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DDNG_WITH_JXL=ON \
      -DDNG_WITH_JPEG=ON \
      -DDNG_WITH_XMP=ON \
      ..
```

This sets:
- `NDEBUG`
- `qDNGUseLibJXL=1`
- `qDNGUseLibJPEG=1`
- `qDNGUseXMP=1`
- `qDNGReportErrors=1` (default)
- `qDNGValidate=0` (default)
- `qDebugPixelType=0` (default)
- `qLogDNGUpdateMetadata=0` (default)
- `qOptGetBitsMath=0` (default)

### Example 2: Minimal Build without XMP

```cmake
cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DDNG_WITH_XMP=OFF \
      -DDNG_WITH_JPEG=OFF \
      -DDNG_WITH_JXL=OFF \
      ..
```

This sets:
- `NDEBUG`
- `qDNGUseXMP=0`
- `qDNGUseLibJPEG` undefined (defaults to 0)
- `qDNGUseLibJXL` undefined (defaults to 0)

### Example 3: Debug Build with Validation

```cmake
cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=Debug \
      -DBUILD_DNG_VALIDATE=ON \
      -DDNG_VALIDATE=ON \
      -DDNG_DEBUG_PIXEL_TYPE=ON \
      -DDNG_LOG_UPDATE_METADATA=ON \
      ..
```

This sets:
- `DEBUG`, `_DEBUG`
- `qDNGDebug=1`
- `qDNGValidateTarget=1` (for dng_validate.cpp only)
- `qDNGValidate=1` (enabled via DNG_VALIDATE option)
- `qDebugPixelType=1` (enabled via DNG_DEBUG_PIXEL_TYPE)
- `qLogDNGUpdateMetadata=1` (enabled via DNG_LOG_UPDATE_METADATA)

---

## Advanced: Direct Preprocessor Override

You can override any preprocessor definition via CMake:

```cmake
# Enable big image support
add_compile_definitions(qDNGBigImage=1)

# Enable AVX even if auto-detection says no
add_compile_definitions(qDNGAVXSupport=1)

# Enable experimental features
add_compile_definitions(qDNGExperimental=1)
```

Or via compiler flags:

```bash
cmake -DCMAKE_CXX_FLAGS="-DqDNGBigImage=1 -DqDNGExperimental=1" ..
```

---

## Default Values Summary

When building with the provided CMakeLists.txt:

**Always Set:**
- Platform: `qWinOS`, `qMacOS`, or `qLinuxOS` = 1
- Threading: `BIB_MULTI_THREAD=1` (if `DNG_THREAD_SAFE=ON`)
- Console: `_CONSOLE=1`
- Unicode: `UNICODE=1`
- JPEG-XL: `JXL_STATIC_DEFINE=1` (if `DNG_WITH_JXL=ON`)

**Conditionally Set:**
- Debug: `DEBUG` and `_DEBUG` (if Debug build)
- Release: `NDEBUG` (if Release build)
- XMP: Platform-specific `WIN_ENV`, `MAC_ENV`, or `UNIX_ENV`

---

## References

- DNG SDK source: `dng_sdk/source/dng_flags.h` - Main flag definitions
- XMP SDK source: `xmp/toolkit/public/include/XMP_Environment.h` - XMP environment
- CMake build: `CMakeLists.txt` - Build system configuration

---

## Notes

1. Most preprocessor definitions are automatically set by `dng_flags.h` and `XMP_Environment.h` based on compiler detection
2. You should rarely need to override these manually
3. The CMake build system handles all platform-specific and feature flags correctly
4. When in doubt, let the build system auto-detect values
5. Only override definitions when you need non-default behavior (e.g., enabling experimental features)
