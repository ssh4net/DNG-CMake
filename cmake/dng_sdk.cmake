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

target_include_directories(dng_sdk
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/dng_sdk/source>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/dng_sdk>
)

# Helper to apply release/debug imported locations consistently.
function(set_imported_library_locations target release_lib debug_lib)
    if(release_lib AND debug_lib)
        # Both debug and release variants exist.
        set_target_properties(${target} PROPERTIES
            IMPORTED_LOCATION_RELEASE "${release_lib}"
            IMPORTED_LOCATION_MINSIZEREL "${release_lib}"
            IMPORTED_LOCATION_RELWITHDEBINFO "${release_lib}"
            IMPORTED_LOCATION_DEBUG "${debug_lib}"
        )
    elseif(release_lib)
        # Only release variant exists, use for all configs.
        set_target_properties(${target} PROPERTIES
            IMPORTED_LOCATION "${release_lib}"
            IMPORTED_LOCATION_RELEASE "${release_lib}"
            IMPORTED_LOCATION_MINSIZEREL "${release_lib}"
            IMPORTED_LOCATION_RELWITHDEBINFO "${release_lib}"
            IMPORTED_LOCATION_DEBUG "${release_lib}"
        )
    elseif(debug_lib)
        # Only debug variant exists, use for all configs.
        set_target_properties(${target} PROPERTIES
            IMPORTED_LOCATION "${debug_lib}"
            IMPORTED_LOCATION_RELEASE "${debug_lib}"
            IMPORTED_LOCATION_MINSIZEREL "${debug_lib}"
            IMPORTED_LOCATION_RELWITHDEBINFO "${debug_lib}"
            IMPORTED_LOCATION_DEBUG "${debug_lib}"
        )
    endif()
endfunction()

# Export required platform macros to consumers (prevents dng_flags.h from including RawEnvironment.h).
if(DEFINED DNG_SDK_PLATFORM_QDEFS)
    target_compile_definitions(dng_sdk PUBLIC ${DNG_SDK_PLATFORM_QDEFS})
endif()

# Ensure validator globals (gVerbose, gDumpLineLimit) are linked from the library
# by forcing qDNGValidate for dng_globals.cpp only, mirroring VS validate build behavior.
set_source_files_properties(
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_globals.cpp
    PROPERTIES COMPILE_DEFINITIONS "qDNGValidate=1"
)


# DNG SDK specific definitions from top-level options
if(DNG_WITH_XMP)
    target_compile_definitions(dng_sdk PUBLIC qDNGUseXMP=1)
    # Provide XMP platform macros to consumers as well (use the same resolved platform as the build/install).
    if(DEFINED XMP_TOOLKIT_INTERFACE_DEFINITIONS)
        target_compile_definitions(dng_sdk PUBLIC ${XMP_TOOLKIT_INTERFACE_DEFINITIONS})
    endif()
else()
    target_compile_definitions(dng_sdk PUBLIC qDNGUseXMP=0)
endif()
if(DNG_WITH_JPEG)
    target_compile_definitions(dng_sdk PUBLIC qDNGUseLibJPEG=1)
endif()
if(DNG_WITH_JXL)
    target_compile_definitions(dng_sdk PUBLIC qDNGUseLibJXL=1)
endif()
target_compile_definitions(dng_sdk PRIVATE qDNGValidateTarget=0)
if(DNG_VALIDATE)
    target_compile_definitions(dng_sdk PRIVATE qDNGValidate=1)
endif()

# Link with dependencies
# Use PUBLIC for static libraries so downstream projects get transitive dependencies
target_link_libraries(dng_sdk PUBLIC Threads::Threads)

# Link XMP libraries if enabled
if(DNG_WITH_XMP)
    target_link_libraries(dng_sdk PUBLIC XMPCoreStatic XMPFilesStatic)
endif()

# Link JPEG library if enabled
if(DNG_WITH_JPEG)
    if(DNG_BUNDLED_JPEG)
        # Use bundled libjpeg - create a simple target
        if(NOT TARGET jpeg::jpeg)
            add_library(jpeg::jpeg INTERFACE IMPORTED)
            target_include_directories(jpeg::jpeg INTERFACE ${CMAKE_SOURCE_DIR}/libjpeg)
            # Note: For bundled JPEG, you would need to build the library separately
            # This is a placeholder - actual implementation would require building libjpeg
            message(WARNING "Bundled JPEG support requires building libjpeg separately")
        endif()
        target_link_libraries(dng_sdk PUBLIC jpeg::jpeg)
    else()
        # Use system libjpeg
        find_package(JPEG REQUIRED)
        target_link_libraries(dng_sdk PUBLIC JPEG::JPEG)
    endif()
endif()

# Link JPEG-XL and dependencies if enabled
if(DNG_WITH_JXL)
    if(DNG_BUNDLED_JXL)
        # Use bundled libjxl - create targets for bundled libraries
        if(NOT TARGET jxl::jxl)
            add_library(jxl::jxl INTERFACE IMPORTED)
            target_include_directories(jxl::jxl INTERFACE 
                ${CMAKE_SOURCE_DIR}/libjxl/libjxl/lib/include
                ${CMAKE_SOURCE_DIR}/libjxl/client_projects/include
            )
            # Note: For bundled JXL, you would need to build the library separately
            # This is a placeholder - actual implementation would require building libjxl
            message(WARNING "Bundled JXL support requires building libjxl separately")
        endif()
        
        # Create placeholder targets for JXL dependencies
        if(NOT TARGET jxl::jxl_threads)
            add_library(jxl::jxl_threads INTERFACE IMPORTED)
        endif()
        if(NOT TARGET hwy::hwy)
            add_library(hwy::hwy INTERFACE IMPORTED)
        endif()
        if(NOT TARGET brotli::brotlicommon)
            add_library(brotli::brotlicommon INTERFACE IMPORTED)
        endif()
        if(NOT TARGET brotli::brotlidec)
            add_library(brotli::brotlidec INTERFACE IMPORTED)
        endif()
        if(NOT TARGET brotli::brotlienc)
            add_library(brotli::brotlienc INTERFACE IMPORTED)
        endif()
        
        target_link_libraries(dng_sdk PUBLIC
            jxl::jxl
            jxl::jxl_threads
            hwy::hwy
            brotli::brotlidec
            brotli::brotlienc
            brotli::brotlicommon
        )
    else()
        # Use system libjxl
        # Find JXL headers for building - exclude bundled sources
        find_path(JXL_INCLUDE_DIR
            NAMES jxl/color_encoding.h
            PATH_SUFFIXES include
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
        )
        if(NOT JXL_INCLUDE_DIR)
            # Fallback to system paths if not found in CMAKE_PREFIX_PATH
            find_path(JXL_INCLUDE_DIR
                NAMES jxl/color_encoding.h
                PATH_SUFFIXES include
                REQUIRED
            )
        endif()
        target_include_directories(dng_sdk PRIVATE ${JXL_INCLUDE_DIR})

        # Link JXL libraries - prefer system libraries over bundled
        # Use NO_DEFAULT_PATH first to search only CMAKE_PREFIX_PATH
        find_library(JXL_LIBRARY_RELEASE
            NAMES jxl
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        find_library(JXL_LIBRARY_DEBUG
            NAMES jxld
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        if(NOT JXL_LIBRARY_RELEASE AND NOT JXL_LIBRARY_DEBUG)
            # Fallback to default search if not in CMAKE_PREFIX_PATH
            find_library(JXL_LIBRARY_RELEASE NAMES jxl)
            find_library(JXL_LIBRARY_DEBUG NAMES jxld)
        endif()

        find_library(JXL_THREADS_LIBRARY_RELEASE
            NAMES jxl_threads
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        find_library(JXL_THREADS_LIBRARY_DEBUG
            NAMES jxl_threadsd
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        if(NOT JXL_THREADS_LIBRARY_RELEASE AND NOT JXL_THREADS_LIBRARY_DEBUG)
            find_library(JXL_THREADS_LIBRARY_RELEASE NAMES jxl_threads)
            find_library(JXL_THREADS_LIBRARY_DEBUG NAMES jxl_threadsd)
        endif()

        find_library(JXL_CMS_LIBRARY_RELEASE
            NAMES jxl_cms
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        find_library(JXL_CMS_LIBRARY_DEBUG
            NAMES jxl_cmsd
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        if(NOT JXL_CMS_LIBRARY_RELEASE AND NOT JXL_CMS_LIBRARY_DEBUG)
            find_library(JXL_CMS_LIBRARY_RELEASE NAMES jxl_cms)
            find_library(JXL_CMS_LIBRARY_DEBUG NAMES jxl_cmsd)
        endif()

        # libjxl_cms depends on lcms2 in many static build setups.
        set(JXL_CMS_DEP_TARGET "")
        if(JXL_CMS_LIBRARY_RELEASE OR JXL_CMS_LIBRARY_DEBUG)
            # Preferred path: use package-provided CMake config.
            find_package(lcms2 CONFIG QUIET)
            if(TARGET lcms2::lcms2)
                set(JXL_CMS_DEP_TARGET lcms2::lcms2)
            else()
                # Fallback for environments that only provide raw libraries.
                find_library(LCMS2_LIBRARY_RELEASE
                    NAMES lcms2
                    NO_DEFAULT_PATH
                    PATHS ${CMAKE_PREFIX_PATH}
                    PATH_SUFFIXES lib lib64
                )
                find_library(LCMS2_LIBRARY_DEBUG
                    NAMES lcms2d lcms2
                    NO_DEFAULT_PATH
                    PATHS ${CMAKE_PREFIX_PATH}
                    PATH_SUFFIXES lib lib64
                )
                if(NOT LCMS2_LIBRARY_RELEASE AND NOT LCMS2_LIBRARY_DEBUG)
                    find_library(LCMS2_LIBRARY_RELEASE NAMES lcms2)
                    find_library(LCMS2_LIBRARY_DEBUG NAMES lcms2d lcms2)
                endif()

                if((LCMS2_LIBRARY_RELEASE OR LCMS2_LIBRARY_DEBUG) AND NOT TARGET lcms2::lcms2)
                    add_library(lcms2::lcms2 UNKNOWN IMPORTED)
                    set_imported_library_locations(lcms2::lcms2 "${LCMS2_LIBRARY_RELEASE}" "${LCMS2_LIBRARY_DEBUG}")
                endif()
                if(TARGET lcms2::lcms2)
                    set(JXL_CMS_DEP_TARGET lcms2::lcms2)
                endif()
            endif()
        endif()

        find_library(HWY_LIBRARY_RELEASE
            NAMES hwy
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        find_library(HWY_LIBRARY_DEBUG
            NAMES hwyd
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        if(NOT HWY_LIBRARY_RELEASE AND NOT HWY_LIBRARY_DEBUG)
            find_library(HWY_LIBRARY_RELEASE NAMES hwy)
            find_library(HWY_LIBRARY_DEBUG NAMES hwyd)
        endif()

        find_library(BROTLI_COMMON_LIBRARY_RELEASE
            NAMES brotlicommon
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        find_library(BROTLI_COMMON_LIBRARY_DEBUG
            NAMES brotlicommond
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        if(NOT BROTLI_COMMON_LIBRARY_RELEASE AND NOT BROTLI_COMMON_LIBRARY_DEBUG)
            find_library(BROTLI_COMMON_LIBRARY_RELEASE NAMES brotlicommon)
            find_library(BROTLI_COMMON_LIBRARY_DEBUG NAMES brotlicommond)
        endif()

        find_library(BROTLI_DEC_LIBRARY_RELEASE
            NAMES brotlidec
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        find_library(BROTLI_DEC_LIBRARY_DEBUG
            NAMES brotlidecd
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        if(NOT BROTLI_DEC_LIBRARY_RELEASE AND NOT BROTLI_DEC_LIBRARY_DEBUG)
            find_library(BROTLI_DEC_LIBRARY_RELEASE NAMES brotlidec)
            find_library(BROTLI_DEC_LIBRARY_DEBUG NAMES brotlidecd)
        endif()

        find_library(BROTLI_ENC_LIBRARY_RELEASE
            NAMES brotlienc
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        find_library(BROTLI_ENC_LIBRARY_DEBUG
            NAMES brotliencd
            NO_DEFAULT_PATH
            PATHS ${CMAKE_PREFIX_PATH}
            PATH_SUFFIXES lib lib64
        )
        if(NOT BROTLI_ENC_LIBRARY_RELEASE AND NOT BROTLI_ENC_LIBRARY_DEBUG)
            find_library(BROTLI_ENC_LIBRARY_RELEASE NAMES brotlienc)
            find_library(BROTLI_ENC_LIBRARY_DEBUG NAMES brotliencd)
        endif()

        # Create imported targets with all configuration variants
        if(NOT TARGET jxl::jxl)
            add_library(jxl::jxl UNKNOWN IMPORTED)
            set_imported_library_locations(jxl::jxl "${JXL_LIBRARY_RELEASE}" "${JXL_LIBRARY_DEBUG}")
        endif()
        
        if(NOT TARGET jxl::jxl_threads)
            add_library(jxl::jxl_threads UNKNOWN IMPORTED)
            set_imported_library_locations(jxl::jxl_threads "${JXL_THREADS_LIBRARY_RELEASE}" "${JXL_THREADS_LIBRARY_DEBUG}")
        endif()

        if((JXL_CMS_LIBRARY_RELEASE OR JXL_CMS_LIBRARY_DEBUG) AND NOT TARGET jxl::jxl_cms)
            add_library(jxl::jxl_cms UNKNOWN IMPORTED)
            set_imported_library_locations(jxl::jxl_cms "${JXL_CMS_LIBRARY_RELEASE}" "${JXL_CMS_LIBRARY_DEBUG}")
        endif()
        if(TARGET jxl::jxl_cms)
            if(JXL_CMS_DEP_TARGET)
                target_link_libraries(jxl::jxl_cms INTERFACE ${JXL_CMS_DEP_TARGET})
            else()
                message(WARNING "Found jxl_cms but could not resolve lcms2 dependency. Static links may fail for jxl_cms users.")
            endif()
        endif()

        if(NOT TARGET hwy::hwy)
            add_library(hwy::hwy UNKNOWN IMPORTED)
            set_imported_library_locations(hwy::hwy "${HWY_LIBRARY_RELEASE}" "${HWY_LIBRARY_DEBUG}")
        endif()

        if(NOT TARGET brotli::brotlicommon)
            add_library(brotli::brotlicommon UNKNOWN IMPORTED)
            set_imported_library_locations(brotli::brotlicommon "${BROTLI_COMMON_LIBRARY_RELEASE}" "${BROTLI_COMMON_LIBRARY_DEBUG}")
        endif()
        
        if(NOT TARGET brotli::brotlidec)
            add_library(brotli::brotlidec UNKNOWN IMPORTED)
            set_imported_library_locations(brotli::brotlidec "${BROTLI_DEC_LIBRARY_RELEASE}" "${BROTLI_DEC_LIBRARY_DEBUG}")
        endif()

        if(NOT TARGET brotli::brotlienc)
            add_library(brotli::brotlienc UNKNOWN IMPORTED)
            set_imported_library_locations(brotli::brotlienc "${BROTLI_ENC_LIBRARY_RELEASE}" "${BROTLI_ENC_LIBRARY_DEBUG}")
        endif()

        # Link all JXL dependencies
        target_link_libraries(dng_sdk PUBLIC
            jxl::jxl
            jxl::jxl_threads
            hwy::hwy
            brotli::brotlidec
            brotli::brotlienc
            brotli::brotlicommon
        )
        if(TARGET jxl::jxl_cms)
            target_link_libraries(dng_sdk PUBLIC jxl::jxl_cms)
        endif()
    endif()
endif()

# Install headers (not part of export, installed separately)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/dng_sdk/source/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/dng_sdk
    FILES_MATCHING PATTERN "*.h"
)
