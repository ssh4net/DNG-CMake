# Documentation Generation Guide

This document explains how the Doxygen documentation generation system works in the DNG SDK CMake build.

## Overview

The build system can optionally generate API documentation for both the DNG SDK and XMP Toolkit using Doxygen. Documentation generation is disabled by default and must be explicitly enabled.

## Prerequisites

### Doxygen Installation

**Ubuntu/Debian:**
```bash
sudo apt install doxygen graphviz
```

**Windows:**
- Download from: https://www.doxygen.nl/download.html
- Install to system PATH or specify `DOXYGEN_EXECUTABLE` CMake variable

**macOS:**
```bash
brew install doxygen graphviz
```

### Graphviz (Optional but Recommended)

Graphviz provides the `dot` tool for generating class diagrams, inheritance graphs, and call graphs. While optional, it significantly enhances documentation quality.

If Graphviz is not found, documentation will still be generated but without diagrams.

## Enabling Documentation

Add `-DBUILD_DOCUMENTATION=ON` to your CMake configuration:

```bash
cmake -DBUILD_DOCUMENTATION=ON ..
```

When enabled, documentation is **automatically built** during the normal build process and **automatically installed** with the standard install target.

## Build Behavior

### Automatic Build (Default)

When `BUILD_DOCUMENTATION=ON`, documentation is generated automatically:

```bash
# Configure with documentation
cmake -DBUILD_DOCUMENTATION=ON ..

# Standard build - documentation is built automatically (via ALL keyword)
cmake --build .

# Standard install - documentation is installed automatically
cmake --install .
```

The `ALL` keyword on documentation targets ensures they are built as part of the default build process.

### Manual Build Targets

You can also build documentation explicitly using specific targets:

#### `docs` (Main Target)
Builds all documentation (DNG SDK + XMP Toolkit)
```bash
cmake --build . --target docs
```

#### `dng_sdk_docs`
Builds only DNG SDK documentation
```bash
cmake --build . --target dng_sdk_docs
```

#### `xmp_docs`
Builds only XMP Toolkit documentation
```bash
cmake --build . --target xmp_docs
```

**Note:** These manual targets are useful for rebuilding documentation without rebuilding the entire project.

## Output Locations

### Build Directory

Documentation is generated in the build directory:
- **DNG SDK**: `build/docs/dng_sdk/html/index.html`
- **XMP Toolkit**: `build/docs/xmp/html/index.html`

### Installation

Documentation is installed automatically with the standard install command:
```bash
cmake --install .
```

No need to specify a component - documentation is part of the default installation.

Installed location (Unix):
- **DNG SDK**: `<prefix>/share/doc/index.html`
- **XMP Toolkit**: `<prefix>/share/xmp/index.html`

Installed location (Windows):
- **DNG SDK**: `<prefix>/doc/index.html`
- **XMP Toolkit**: `<prefix>/xmp/index.html`

## Configuration Files

### DNG SDK: `cmake/doxygen.cfg.in`

Template Doxyfile for DNG SDK documentation, based on the original Adobe DNG SDK 1.5.1 configuration. Key settings:
- **INPUT**: `dng_sdk/source/` directory and `cmake/mainpage.dox`
- **FILE_PATTERNS**: `*.c *.cc *.cxx *.cpp *.c++ *.h *.hh *.hxx *.hpp *.h++ *.dox`
- **EXTRACT_ALL**: YES (documents all entities)
- **SOURCE_BROWSER**: YES (includes source code)
- **GENERATE_HTML**: YES
- **GENERATE_LATEX**: NO
- **SEARCHENGINE**: YES (enables HTML search)
- **GENERATE_TREEVIEW**: YES (tree navigation)

CMake variables substituted:
- `@PROJECT_VERSION@` - Project version (e.g., 1.7.1)
- `@DOXYGEN_OUTPUT_DIR@` - Output directory path
- `@CMAKE_SOURCE_DIR@` - Source root directory
- `@DOXYGEN_HAVE_DOT@` - YES/NO based on Graphviz detection

### DNG SDK: `cmake/mainpage.dox`

Main documentation page with introduction and starting points. References:
- Key classes: `dng_host`, `dng_negative`, `dng_image`, `dng_render`, `dng_image_writer`
- Command-line tool: `dng_validate`
- Related specifications: DNG, TIFF, EXIF, IPTC

### XMP Toolkit: `xmp/toolkit/build/Doxyfile`

Pre-existing Doxyfile from XMP SDK. The CMake system modifies it at build time to:
- Update `OUTPUT_DIRECTORY` to point to build directory
- Set `PROJECT_NUMBER` to current version
- Fix `INPUT` paths (original references non-existent `../../documents/toolkit`)
- Set `INPUT` to all XMP toolkit directories except third-party:
  - `public/` - Public API headers
  - `source/` - Implementation source files
  - `XMPCommon/` - Common XMP functionality
  - `XMPCompareAndMerge/` - Compare and merge features
  - `XMPCore/` - Core XMP implementation
  - `XMPExtensions/` - XMP extensions
  - `XMPFiles/` - File format handlers
  - `XMPFilesPlugins/` - Plugin system
  - `XMPScript/` - Scripting support
  - `XMPWasm/` - WebAssembly support
- Enable `RECURSIVE = YES` to scan all subdirectories
- Enable comprehensive documentation features to match DNG SDK quality:
  - `EXTRACT_ALL = YES` - Documents all entities (not just documented ones)
  - `SOURCE_BROWSER = YES` - Includes source code browsing
  - `GENERATE_TREEVIEW = YES` - Enables tree navigation sidebar
  - `SEARCHENGINE = YES` - Enables HTML search functionality
- Remove obsolete tags for newer Doxygen versions
- Clear broken references to missing HTML customization files

## Preprocessor Definitions

The DNG SDK Doxyfile includes common preprocessor definitions to ensure correct code parsing:

```
qDNGBigEndian=0
qDNGThreadSafe=1
qDNGUseLibJPEG=1
qDNGUseXMP=1
qDNGValidate=0
qDNG64Bit=1
```

These match typical build configurations and ensure Doxygen correctly processes conditional compilation blocks.

## Documentation Content

### DNG SDK Documentation

Covers:
- Core classes (`dng_host`, `dng_negative`, `dng_image`, `dng_stream`)
- File I/O (`dng_file_stream`, `dng_memory_stream`)
- Image processing (`dng_render`, `dng_resample`, `dng_filter_task`)
- Metadata handling (`dng_exif`, `dng_iptc`, `dng_xmp`)
- Format support (`dng_jpeg_image`, `dng_jxl`, `dng_lossless_jpeg`)
- Utilities (`dng_utils`, `dng_safe_arithmetic`, `dng_matrix`)

### XMP Toolkit Documentation

Covers all XMP toolkit modules (excluding third-party):
- **XMPCore**: RDF parsing, metadata manipulation, serialization
- **XMPFiles**: File format handlers, smart handlers
- **XMPCommon**: Common utilities and base functionality
- **XMPCompareAndMerge**: Metadata comparison and merging features
- **XMPExtensions**: Extension mechanisms and plugins
- **XMPFilesPlugins**: Plugin system architecture
- **XMPScript**: Scripting API and bindings
- **XMPWasm**: WebAssembly implementation
- **Public API**: Template-based API (`TXMPMeta`, `TXMPFiles`, `TXMPIterator`, etc.)
- **Implementation**: Source code and internal details

## Implementation Details

### CMake Module: `cmake/doxygen.cmake`

The documentation system is implemented in `cmake/doxygen.cmake`, which:

1. **Checks for BUILD_DOCUMENTATION option** - Returns early if disabled
2. **Finds Doxygen** using `find_package(Doxygen)`
3. **Detects Graphviz** and sets `DOXYGEN_HAVE_DOT`
4. **Configures DNG SDK Doxyfile** from template
5. **Creates `dng_sdk_docs` target** with `ALL` keyword
6. **Processes XMP Doxyfile** if `DNG_WITH_XMP=ON`
7. **Creates `xmp_docs` target** with `ALL` keyword
8. **Creates `docs` meta-target** with `ALL` keyword that depends on both
9. **Sets up installation rules** as part of default installation

### Custom Target Workflow

Documentation is generated automatically during builds when `BUILD_DOCUMENTATION=ON`:

```cmake
add_custom_target(dng_sdk_docs ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory ${OUTPUT_DIR}
    COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYFILE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating DNG SDK documentation with Doxygen"
    VERBATIM
)
```

The `ALL` keyword ensures documentation is built as part of the default build target, so running `cmake --build .` will generate documentation automatically.

Documentation is also installed automatically as part of the default installation (no separate component needed).

### Incremental Build Optimization

The documentation system uses `add_custom_command()` with `OUTPUT` to track documentation generation:

```cmake
add_custom_command(
    OUTPUT ${DNG_DOCS_STAMP_FILE}
    COMMAND ${DOXYGEN_EXECUTABLE} ${DNG_DOXYFILE_OUT}
    DEPENDS ${DNG_DOXYFILE_OUT}
    ...
)
```

This provides several benefits:

- **Skips regeneration during install** - If documentation was built during the ALL_BUILD step, `cmake --install .` will not regenerate it
- **Dependency tracking** - Documentation only regenerates when Doxyfile changes
- **Timestamp checking** - Uses `index.html` as a stamp file to determine if documentation is up-to-date
- **Faster incremental builds** - Subsequent builds skip documentation if nothing changed

## Troubleshooting

### Doxygen Not Found

**Error**: "Doxygen not found. Documentation generation disabled."

**Solution**: Install Doxygen and ensure it's in your system PATH, or set:
```bash
cmake -DDOXYGEN_EXECUTABLE=/path/to/doxygen ..
```

### Missing Diagrams

**Symptom**: Documentation builds but lacks class diagrams and graphs.

**Solution**: Install Graphviz:
```bash
# Ubuntu/Debian
sudo apt install graphviz

# Windows
Download from https://graphviz.org/download/

# macOS
brew install graphviz
```

### XMP Documentation Not Generated

**Cause**: XMP documentation depends on `DNG_WITH_XMP=ON` and existence of `xmp/toolkit/build/Doxyfile`.

**Solution**: Ensure XMP SDK is properly extracted and `DNG_WITH_XMP=ON` in CMake configuration.

### Warnings About Undocumented Members

This is normal. The DNG SDK and XMP Toolkit have varying levels of documentation. The Doxyfile is configured with:
- `WARN_IF_UNDOCUMENTED = NO`
- `EXTRACT_ALL = YES`

This ensures all code is documented even if inline documentation is sparse.

## Integration with IDEs

### Visual Studio

Documentation targets appear in the Solution Explorer under "CMakePredefinedTargets". Right-click and select "Build" to generate docs.

### Qt Creator / CLion

Documentation targets appear in the build configuration dropdown. Select the target and build normally.

### Command Line

Always use:
```bash
cmake --build . --target docs
```

This works across all generators (Ninja, Make, Visual Studio, Xcode).

## Performance Notes

- **Initial generation**: 1-5 minutes depending on system and whether Graphviz is enabled
- **Incremental builds**: Doxygen regenerates all documentation each time (no incremental support)
- **Output size**:
  - DNG SDK HTML: ~15-30 MB
  - XMP Toolkit HTML: ~20-40 MB
  - With diagrams: +50% size increase

## Related Files

- `CMakeLists.txt` - Adds `BUILD_DOCUMENTATION` option and includes `cmake/doxygen.cmake`
- `cmake/doxygen.cmake` - Main documentation generation logic
- `dng_sdk/Doxyfile.in` - DNG SDK Doxygen configuration template
- `xmp/toolkit/build/Doxyfile` - XMP Toolkit Doxygen configuration (from Adobe)
- `README.md` - User-facing documentation build instructions
- `CLAUDE.md` - Developer documentation with build examples

## Future Enhancements

Potential improvements:
- **PDF generation**: Enable `GENERATE_LATEX=YES` and add PDF build target
- **Man pages**: Enable `GENERATE_MAN=YES` for Unix man pages
- **XML output**: Enable `GENERATE_XML=YES` for further processing
- **Custom CSS**: Add custom stylesheet for branded documentation
- **Versioned docs**: Support multiple version installations
- **Online hosting**: Integration with GitHub Pages or Read the Docs

## License and Credits

Documentation generation uses:
- **Doxygen**: GPL licensed, www.doxygen.nl
- **Graphviz**: Eclipse Public License, www.graphviz.org

The generated documentation is derivative work of:
- Adobe DNG SDK (Adobe Systems Incorporated)
- XMP Toolkit (Adobe Systems Incorporated)

Refer to original SDK licenses for distribution terms.
