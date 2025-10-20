# DNG SDK static library
add_library(dng_sdk STATIC
    # Core DNG SDK source files
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_1d_function.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_1d_table.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_abort_sniffer.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_area_task.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_bad_pixels.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_big_table.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_bmff.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_bottlenecks.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_camera_profile.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_color_space.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_color_spec.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_date_time.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_exceptions.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_exif.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_file_stream.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_filter_task.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_fingerprint.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_gain_map.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_globals.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_host.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_hue_sat_map.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_ifd.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_image.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_image_writer.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_info.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_iptc.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_jpeg_image.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_jpeg_memory_source.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_jxl.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_lens_correction.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_linearization_info.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_local_string.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_lossless_jpeg.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_lossless_jpeg_shared.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_matrix.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_memory.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_memory_stream.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_misc_opcodes.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_mosaic_info.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_mutex.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_negative.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_opcodes.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_opcode_list.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_orientation.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_parse_utils.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_pixel_buffer.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_point.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_preview.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_pthread.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_rational.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_read_image.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_rect.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_reference.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_ref_counted_block.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_render.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_resample.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_safe_arithmetic.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_shared.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_simple_image.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_spline.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_stream.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_string.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_string_list.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_tag_types.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_temperature.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_tile_iterator.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_tone_curve.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_update_meta.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_utils.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_xmp.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_xmp_sdk.cpp
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_xy_coord.cpp
)

set_target_properties(dng_sdk PROPERTIES
    DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}
)

# Ensure validator globals (gVerbose, gDumpLineLimit) are linked from the library
# by forcing qDNGValidate for dng_globals.cpp only, mirroring VS validate build behavior.
set_source_files_properties(
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_globals.cpp
    PROPERTIES COMPILE_DEFINITIONS "qDNGValidate=1"
)

# Locate libjxl headers (required when qDNGUseLibJXL=1)
find_path(JXL_INCLUDE_DIR NAMES jxl/color_encoding.h PATH_SUFFIXES include)
if(NOT JXL_INCLUDE_DIR)
    message(FATAL_ERROR "libjxl headers not found (jxl/color_encoding.h). Set CMAKE_PREFIX_PATH to the JXL install prefix or provide headers in the repository.")
endif()

target_include_directories(dng_sdk PRIVATE
    ${JXL_INCLUDE_DIR}
)

# DNG SDK specific definitions from top-level options
if(DNG_WITH_XMP)
    target_compile_definitions(dng_sdk PRIVATE qDNGUseXMP=1)
    # Propagate XMP environment macros for code that includes XMP public headers
    if(EMSCRIPTEN)
        target_compile_definitions(dng_sdk PRIVATE WEB_ENV XMP_WebBuild)
    elseif(ANDROID)
        target_compile_definitions(dng_sdk PRIVATE ANDROID_ENV XMP_AndroidBuild)
    elseif(APPLE)
        if(IOS OR CMAKE_SYSTEM_NAME STREQUAL "iOS")
            target_compile_definitions(dng_sdk PRIVATE IOS_ENV XMP_iOSBuild)
        else()
            target_compile_definitions(dng_sdk PRIVATE MAC_ENV XMP_MacBuild)
        endif()
    elseif(WIN32)
        target_compile_definitions(dng_sdk PRIVATE WIN_ENV XMP_WinBuild)
    else()
        target_compile_definitions(dng_sdk PRIVATE UNIX_ENV XMP_UNIXBuild)
    endif()
endif()
if(DNG_WITH_JPEG)
    target_compile_definitions(dng_sdk PRIVATE qDNGUseLibJPEG=1)
endif()
if(DNG_WITH_JXL)
    target_compile_definitions(dng_sdk PRIVATE qDNGUseLibJXL=1)
endif()
target_compile_definitions(dng_sdk PRIVATE qDNGValidateTarget=0 qDNGValidate=0)

# Link with XMP libraries if enabled
target_link_libraries(dng_sdk PRIVATE Threads::Threads)
if(DNG_WITH_XMP)
    target_link_libraries(dng_sdk PRIVATE XMPCoreStatic XMPFilesStatic)
endif()

# Install headers
install(DIRECTORY ${CMAKE_SOURCE_DIR}/dng_sdk/source/
    DESTINATION include/dng_sdk
    FILES_MATCHING PATTERN "*.h"
)

# Install the static library
install(TARGETS dng_sdk
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)