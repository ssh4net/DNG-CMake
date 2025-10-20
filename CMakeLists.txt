cmake_minimum_required(VERSION 3.16)
project(dng_sdk VERSION 1.7.1 LANGUAGES C CXX)
# Respect CMAKE_DEBUG_POSTFIX (default to "d" if not set)
if(NOT DEFINED CMAKE_DEBUG_POSTFIX)
    set(CMAKE_DEBUG_POSTFIX "d")
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE)
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
set(XMP_ROOT "${CMAKE_SOURCE_DIR}/xmp" CACHE PATH "Path to XMP toolkit root (folder containing toolkit/) if not in repo")
set(CMAKE_PREFIX_PATH "" CACHE STRING "Semicolon-separated list of directories specifying installation prefixes to be searched")

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
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_definitions(DEBUG _DEBUG)
else()
    add_compile_definitions(NDEBUG)
endif()

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
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/third-party/zlib
    ${CMAKE_SOURCE_DIR}/libjxl/libjxl/lib/include
    ${CMAKE_SOURCE_DIR}/libjxl/client_projects/include
    ${CMAKE_SOURCE_DIR}/libjpeg
)

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

# Install rules
install(TARGETS dng_validate
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

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