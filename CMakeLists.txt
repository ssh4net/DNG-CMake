cmake_minimum_required(VERSION 3.16)
project(dng_sdk VERSION 1.7.1 LANGUAGES C CXX)

# Preserve important cache variables across reconfigurations
if(NOT DEFINED CMAKE_MSVC_RUNTIME_LIBRARY)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>" CACHE STRING "MSVC runtime library")
endif()

if(NOT DEFINED CMAKE_DEBUG_POSTFIX)
    set(CMAKE_DEBUG_POSTFIX "d" CACHE STRING "Debug postfix for libraries")
endif()

if(NOT DEFINED CMAKE_PREFIX_PATH)
    set(CMAKE_PREFIX_PATH "" CACHE STRING "Semicolon-separated list of directories specifying installation prefixes to be searched")
endif()

# Additional important cache variables
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/install" CACHE PATH "Installation directory")
endif()


set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Set default build type if not specified (only for single-config generators)
get_property(IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(NOT IS_MULTI_CONFIG AND NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
endif()

# Use clang if requested (exclude clang-cl on Windows/MSVC toolchain)
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" AND NOT MSVC)
    message(STATUS "Using Clang compiler with libc++")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++")
endif()

# Build options (portable, align with VS solution defaults)
option(BUILD_DNG_VALIDATE "Build the dng_validate tool" ON)
option(DNG_THREAD_SAFE "Enable thread-safe DNG SDK (BIB_MULTI_THREAD)" ON)
option(DNG_WITH_JPEG "Enable libjpeg usage in DNG SDK" ON)
option(DNG_WITH_JXL "Enable libjxl usage in DNG SDK" ON)
option(DNG_WITH_XMP "Enable XMP SDK and link into DNG SDK" ON)

# Bundled library options (system libraries preferred by default)
option(DNG_BUNDLED_JPEG "Use bundled libjpeg instead of system library" OFF)
option(DNG_BUNDLED_JXL "Use bundled libjxl instead of system library" OFF)
option(XMP_USE_SYSTEM_ZLIB "Use system zlib instead of bundled version" ON)
option(XMP_USE_SYSTEM_BOOST "Use system Boost UUID headers instead of bundled copy" OFF)

# DNG SDK debug and diagnostic options
option(DNG_REPORT_ERRORS "Enable error reporting (qDNGReportErrors)" ON)
option(DNG_VALIDATE "Enable validation checks (qDNGValidate)" OFF)
option(DNG_DEBUG_PIXEL_TYPE "Enable pixel type debugging (qDebugPixelType)" OFF)
option(DNG_LOG_UPDATE_METADATA "Log metadata update operations (qLogDNGUpdateMetadata)" OFF)
option(DNG_OPT_GETBITS_MATH "Use optimized bit extraction math (qOptGetBitsMath)" OFF)

set(XMP_ROOT "${CMAKE_SOURCE_DIR}/xmp" CACHE PATH "Path to XMP toolkit root (folder containing toolkit/) if not in repo")

# Common definitions for all targets
add_compile_definitions(
    _CONSOLE
    _CRT_SECURE_NO_DEPRECATE
    UNICODE
    JXL_STATIC_DEFINE=1
)

if(DNG_THREAD_SAFE)
    add_compile_definitions(BIB_MULTI_THREAD=1)
else()
    add_compile_definitions(BIB_MULTI_THREAD=0)
endif()

if(DNG_WITH_JPEG)
    add_compile_definitions(qDNGUseLibJPEG=1)
endif()

if(DNG_WITH_JXL)
    add_compile_definitions(qDNGUseLibJXL=1)
endif()

if(DNG_WITH_XMP)
    add_compile_definitions(qDNGUseXMP=1)
else()
    add_compile_definitions(qDNGUseXMP=0)
endif()

# Apply debug and diagnostic options
if(DNG_REPORT_ERRORS)
    add_compile_definitions(qDNGReportErrors=1)
else()
    add_compile_definitions(qDNGReportErrors=0)
endif()

if(DNG_VALIDATE)
    add_compile_definitions(qDNGValidate=1)
else()
    add_compile_definitions(qDNGValidate=0)
endif()

if(DNG_DEBUG_PIXEL_TYPE)
    add_compile_definitions(qDebugPixelType=1)
else()
    add_compile_definitions(qDebugPixelType=0)
endif()

if(DNG_LOG_UPDATE_METADATA)
    add_compile_definitions(qLogDNGUpdateMetadata=1)
else()
    add_compile_definitions(qLogDNGUpdateMetadata=0)
endif()

if(DNG_OPT_GETBITS_MATH)
    add_compile_definitions(qOptGetBitsMath=1)
else()
    add_compile_definitions(qOptGetBitsMath=0)
endif()

# Platform-specific preprocessor macros to mirror Visual Studio projects
if(WIN32)
    add_compile_definitions(
        qWinOS=1
        qMacOS=0
        qLinuxOS=0
        qVisualC=1
        _WINDOWS=1
        WIN32
    )
elseif(APPLE)
    add_compile_definitions(
        qWinOS=0
        qMacOS=1
        qLinuxOS=0
        qVisualC=0
    )
else()
    add_compile_definitions(
        qWinOS=0
        qMacOS=0
        qLinuxOS=1
        qVisualC=0
    )
endif()

# Platform-specific settings
# Use generator expressions for multi-config generators (VS, Xcode)
add_compile_definitions(
    $<$<CONFIG:Debug>:DEBUG>
    $<$<CONFIG:Debug>:_DEBUG>
    $<$<NOT:$<CONFIG:Debug>>:NDEBUG>
)

# Enable position independent code for all targets
set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "Build position independent code")

# Honor CMAKE_PREFIX_PATH by default: add <prefix>/include and <prefix>/lib
if(CMAKE_PREFIX_PATH)
    foreach(_prefix IN LISTS CMAKE_PREFIX_PATH)
        if(EXISTS "${_prefix}/include")
            include_directories("${_prefix}/include")
        endif()
        if(EXISTS "${_prefix}/lib")
            link_directories("${_prefix}/lib")
        endif()
    endforeach()
endif()

# Also support the environment variable CMAKE_PREFIX_PATH if passed as a single string
if(NOT CMAKE_PREFIX_PATH AND DEFINED ENV{CMAKE_PREFIX_PATH})
    separate_arguments(_env_prefixes WINDOWS_COMMAND "$ENV{CMAKE_PREFIX_PATH}")
    foreach(_prefix IN LISTS _env_prefixes)
        if(EXISTS "${_prefix}/include")
            include_directories("${_prefix}/include")
        endif()
        if(EXISTS "${_prefix}/lib")
            link_directories("${_prefix}/lib")
        endif()
    endforeach()
endif()

# Include directories for all targets
include_directories(
    ${CMAKE_SOURCE_DIR}/dng_sdk/source
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/public/include
)

# Conditional include directories based on bundled library options
if(DNG_BUNDLED_JPEG)
    include_directories(${CMAKE_SOURCE_DIR}/libjpeg)
endif()

if(DNG_BUNDLED_JXL)
    include_directories(
        ${CMAKE_SOURCE_DIR}/libjxl/libjxl/lib/include
        ${CMAKE_SOURCE_DIR}/libjxl/client_projects/include
    )
endif()

if(NOT XMP_USE_SYSTEM_ZLIB)
    include_directories(${CMAKE_SOURCE_DIR}/xmp/toolkit/third-party/zlib)
endif()

# Standard installation directories
include(GNUInstallDirs)

# Find required packages
find_package(Threads REQUIRED)

# Add subdirectories for different components (CMake files live under cmake/*)
if(DNG_WITH_XMP)
    include(cmake/xmp.cmake)
endif()
include(cmake/dng_sdk.cmake)
if(BUILD_DNG_VALIDATE)
    include(cmake/dng_validate.cmake)
endif()

#
# Installation and Package Configuration
#

# Export targets for installation
set(DNG_SDK_EXPORT_TARGETS dng_sdk)
if(BUILD_DNG_VALIDATE)
    list(APPEND DNG_SDK_EXPORT_TARGETS dng_validate)
endif()

# Install DNG SDK targets with export
install(TARGETS ${DNG_SDK_EXPORT_TARGETS}
    EXPORT dng_sdk-targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Install XMP Toolkit targets separately with their own export
if(DNG_WITH_XMP)
    install(TARGETS XMPCoreStatic XMPFilesStatic
        EXPORT XMPToolkit-targets
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endif()

# Install the export set
install(EXPORT dng_sdk-targets
    FILE dng_sdk-targets.cmake
    NAMESPACE dng_sdk::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/dng_sdk
)

# Generate and install package config files
include(CMakePackageConfigHelpers)

# Configure the config file
configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/dng_sdk-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/dng_sdk-config.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/dng_sdk
    PATH_VARS CMAKE_INSTALL_INCLUDEDIR CMAKE_INSTALL_LIBDIR CMAKE_INSTALL_BINDIR
)

# Generate the version file
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/dng_sdk-config-version.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

# Install config files
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/dng_sdk-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/dng_sdk-config-version.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/dng_sdk
)

# Generate and install XMP Toolkit package config files (if XMP is enabled)
if(DNG_WITH_XMP)
    # Install XMP targets separately
    install(EXPORT XMPToolkit-targets
        FILE XMPToolkit-targets.cmake
        NAMESPACE XMP::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/XMPToolkit
    )

    # Configure XMP Toolkit config file
    configure_package_config_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/XMPToolkit-config.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/XMPToolkit-config.cmake
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/XMPToolkit
        PATH_VARS CMAKE_INSTALL_INCLUDEDIR CMAKE_INSTALL_LIBDIR
    )

    # Generate XMP Toolkit version file
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/XMPToolkit-config-version.cmake
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    # Install XMP Toolkit config files
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/XMPToolkit-config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/XMPToolkit-config-version.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/XMPToolkit
    )

    # Configure XMP Toolkit pkg-config file
    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/XMPToolkit.pc.in
        ${CMAKE_CURRENT_BINARY_DIR}/XMPToolkit.pc
        @ONLY
    )

    # Install XMP Toolkit pkg-config file
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/XMPToolkit.pc
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
    )
endif()

# Generate and install pkg-config files
# Build pkg-config variables for dng_sdk.pc
set(DNG_SDK_PC_REQUIRES "")
set(DNG_SDK_PC_REQUIRES_PRIVATE "")
set(DNG_SDK_PC_LIBS_PRIVATE "-pthread")
set(DNG_SDK_PC_CFLAGS "")

if(DNG_WITH_XMP)
    list(APPEND DNG_SDK_PC_REQUIRES_PRIVATE "XMPCoreStatic" "XMPFilesStatic")
endif()
if(DNG_WITH_JPEG AND NOT DNG_BUNDLED_JPEG)
    list(APPEND DNG_SDK_PC_REQUIRES_PRIVATE "libjpeg")
    set(DNG_SDK_PC_CFLAGS "${DNG_SDK_PC_CFLAGS} -DqDNGUseLibJPEG=1")
endif()
if(DNG_WITH_JXL AND NOT DNG_BUNDLED_JXL)
    list(APPEND DNG_SDK_PC_REQUIRES_PRIVATE "libjxl" "libjxl_threads" "libhwy" "libbrotlicommon" "libbrotlidec" "libbrotlienc")
    set(DNG_SDK_PC_CFLAGS "${DNG_SDK_PC_CFLAGS} -DqDNGUseLibJXL=1 -DJXL_STATIC_DEFINE=1")
endif()
if(DNG_THREAD_SAFE)
    set(DNG_SDK_PC_CFLAGS "${DNG_SDK_PC_CFLAGS} -DBIB_MULTI_THREAD=1")
else()
    set(DNG_SDK_PC_CFLAGS "${DNG_SDK_PC_CFLAGS} -DBIB_MULTI_THREAD=0")
endif()

# Convert lists to space-separated strings
string(REPLACE ";" " " DNG_SDK_PC_REQUIRES "${DNG_SDK_PC_REQUIRES}")
string(REPLACE ";" " " DNG_SDK_PC_REQUIRES_PRIVATE "${DNG_SDK_PC_REQUIRES_PRIVATE}")

# XMP pkg-config variables
set(XMP_PC_CFLAGS "")
if(WIN32)
    set(XMP_PC_CFLAGS "-DWIN_ENV -DXMP_WinBuild")
elseif(APPLE)
    set(XMP_PC_CFLAGS "-DMAC_ENV -DXMP_MacBuild")
else()
    set(XMP_PC_CFLAGS "-DUNIX_ENV -DXMP_UNIXBuild")
endif()

# Configure pkg-config files
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/dng_sdk.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/dng_sdk.pc
    @ONLY
)

if(DNG_WITH_XMP)
    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/XMPCoreStatic.pc.in
        ${CMAKE_CURRENT_BINARY_DIR}/XMPCoreStatic.pc
        @ONLY
    )
    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/XMPFilesStatic.pc.in
        ${CMAKE_CURRENT_BINARY_DIR}/XMPFilesStatic.pc
        @ONLY
    )
endif()

# Install pkg-config files
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/dng_sdk.pc
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)

if(DNG_WITH_XMP)
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/XMPCoreStatic.pc
        ${CMAKE_CURRENT_BINARY_DIR}/XMPFilesStatic.pc
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
    )
endif()

# Apply patch to dng_jxl.cpp if needed
if(DNG_WITH_JXL)
    set(PATCH_FILE "${CMAKE_SOURCE_DIR}/cmake/dng_jxl.patch")
    set(TARGET_FILE "${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_jxl.cpp")
    
    # Check if patch is already applied
    execute_process(
        COMMAND git apply --check --reverse --unsafe-paths --directory=dng_sdk/source ${PATCH_FILE}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        RESULT_VARIABLE PATCH_ALREADY_APPLIED
        OUTPUT_QUIET
        ERROR_QUIET
    )
    
    if(PATCH_ALREADY_APPLIED EQUAL 0)
        message(STATUS "Patch dng_jxl.patch: Already applied to ${TARGET_FILE}")
    else()
        # Try to apply the patch
        execute_process(
            COMMAND git apply --check --unsafe-paths --directory=dng_sdk/source ${PATCH_FILE}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            RESULT_VARIABLE PATCH_CHECK_RESULT
            OUTPUT_QUIET
            ERROR_QUIET
        )
        
        if(PATCH_CHECK_RESULT EQUAL 0)
            # Patch can be applied, apply it
            execute_process(
                COMMAND git apply --unsafe-paths --directory=dng_sdk/source ${PATCH_FILE}
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                RESULT_VARIABLE PATCH_APPLY_RESULT
                OUTPUT_VARIABLE PATCH_OUTPUT
                ERROR_VARIABLE PATCH_ERROR
            )
            
            if(PATCH_APPLY_RESULT EQUAL 0)
                message(STATUS "Patch dng_jxl.patch: Successfully applied to ${TARGET_FILE}")
            else()
                message(WARNING "Patch dng_jxl.patch: Failed to apply\n${PATCH_ERROR}")
            endif()
        else()
            message(WARNING "Patch dng_jxl.patch: Cannot apply - file may be modified or in unexpected state")
        endif()
    endif()
endif()