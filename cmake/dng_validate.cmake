# DNG Validate executable
add_executable(dng_validate
    ${CMAKE_SOURCE_DIR}/dng_sdk/source/dng_validate.cpp
)

set_target_properties(dng_validate PROPERTIES
    DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}
)

# dng_validate specific definitions
target_compile_definitions(dng_validate PRIVATE qDNGValidateTarget=1 qDNGValidate=1)
if(DNG_WITH_XMP)
    target_compile_definitions(dng_validate PRIVATE qDNGUseXMP=1)
endif()

# Link with DNG SDK and dependencies
target_link_libraries(dng_validate PRIVATE dng_sdk Threads::Threads)
if(DNG_WITH_XMP)
    target_link_libraries(dng_validate PRIVATE XMPCoreStatic XMPFilesStatic)
endif()

# Platform-specific linking
if(WIN32)
    # Prefer static libraries similar to VS project entries
    find_library(JPEG_RELEASE NAMES jpeg libjpeg)
    find_library(JPEG_DEBUG   NAMES jpegd libjpegd)
    if(JPEG_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${JPEG_RELEASE})
    endif()
    if(JPEG_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${JPEG_DEBUG})
    endif()

    find_library(JXL_CMS_RELEASE NAMES jxl_cms)
    find_library(JXL_CMS_DEBUG   NAMES jxl_cmsd)
    if(JXL_CMS_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${JXL_CMS_RELEASE})
    endif()
    if(JXL_CMS_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${JXL_CMS_DEBUG})
    endif()

    find_library(JXL_THREADS_RELEASE NAMES jxl_threads)
    find_library(JXL_THREADS_DEBUG   NAMES jxl_threadsd)
    if(JXL_THREADS_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${JXL_THREADS_RELEASE})
    endif()
    if(JXL_THREADS_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${JXL_THREADS_DEBUG})
    endif()

    find_library(JXL_RELEASE NAMES jxl)
    find_library(JXL_DEBUG   NAMES jxld)
    if(JXL_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${JXL_RELEASE})
    endif()
    if(JXL_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${JXL_DEBUG})
    endif()

    find_library(HWY_RELEASE NAMES hwy)
    find_library(HWY_DEBUG   NAMES hwyd)
    if(HWY_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${HWY_RELEASE})
    endif()
    if(HWY_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${HWY_DEBUG})
    endif()

    find_library(BROTLI_COMMON_RELEASE NAMES brotlicommon)
    find_library(BROTLI_COMMON_DEBUG   NAMES brotlicommond)
    if(BROTLI_COMMON_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${BROTLI_COMMON_RELEASE})
    endif()
    if(BROTLI_COMMON_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${BROTLI_COMMON_DEBUG})
    endif()

    find_library(BROTLI_DEC_RELEASE NAMES brotlidec)
    find_library(BROTLI_DEC_DEBUG   NAMES brotlidecd)
    if(BROTLI_DEC_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${BROTLI_DEC_RELEASE})
    endif()
    if(BROTLI_DEC_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${BROTLI_DEC_DEBUG})
    endif()

    find_library(BROTLI_ENC_RELEASE NAMES brotlienc)
    find_library(BROTLI_ENC_DEBUG   NAMES brotliencd)
    if(BROTLI_ENC_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${BROTLI_ENC_RELEASE})
    endif()
    if(BROTLI_ENC_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${BROTLI_ENC_DEBUG})
    endif()

    find_library(BZIP2_RELEASE NAMES bz2)
    find_library(BZIP2_DEBUG   NAMES bz2d)
    if(BZIP2_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${BZIP2_RELEASE})
    endif()
    if(BZIP2_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${BZIP2_DEBUG})
    endif()

    find_library(DEFLATE_RELEASE NAMES deflatestatic)
    find_library(DEFLATE_DEBUG   NAMES deflatestaticd)
    if(DEFLATE_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${DEFLATE_RELEASE})
    endif()
    if(DEFLATE_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${DEFLATE_DEBUG})
    endif()

    find_library(ZLIB_RELEASE NAMES zlib z)
    find_library(ZLIB_DEBUG   NAMES zlibd zd)
    if(ZLIB_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${ZLIB_RELEASE})
    endif()
    if(ZLIB_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${ZLIB_DEBUG})
    endif()

    find_library(ZSTD_RELEASE NAMES zstd_static zstd)
    find_library(ZSTD_DEBUG   NAMES zstd_staticd zstdd)
    if(ZSTD_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${ZSTD_RELEASE})
    endif()
    if(ZSTD_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${ZSTD_DEBUG})
    endif()

    find_library(LZMA_RELEASE NAMES lzma)
    find_library(LZMA_DEBUG   NAMES lzmad)
    if(LZMA_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${LZMA_RELEASE})
    endif()
    if(LZMA_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${LZMA_DEBUG})
    endif()

    find_library(EXPAT_RELEASE NAMES libexpatMT libexpatMD libexpat expat)
    find_library(EXPAT_DEBUG   NAMES libexpatdMT libexpatdMD libexpatd expatd)
    if(EXPAT_RELEASE)
        target_link_libraries(dng_validate PRIVATE optimized ${EXPAT_RELEASE})
    endif()
    if(EXPAT_DEBUG)
        target_link_libraries(dng_validate PRIVATE debug ${EXPAT_DEBUG})
    endif()

elseif(UNIX AND NOT APPLE)
    target_link_libraries(dng_validate PRIVATE
        dl
        rt
        m
    )
    
    # Find and link with system libraries for JPEG and JXL if available
    find_library(JPEG_LIBRARY NAMES jpeg)
    if(JPEG_LIBRARY)
        target_link_libraries(dng_validate PRIVATE ${JPEG_LIBRARY})
    endif()
    
    find_library(JXL_LIBRARY NAMES jxl)
    if(JXL_LIBRARY)
        target_link_libraries(dng_validate PRIVATE ${JXL_LIBRARY})
    endif()
    
    find_library(JXL_THREADS_LIBRARY NAMES jxl_threads)
    if(JXL_THREADS_LIBRARY)
        target_link_libraries(dng_validate PRIVATE ${JXL_THREADS_LIBRARY})
    endif()
    
    find_library(JXL_CMS_LIBRARY NAMES jxl_cms)
    if(JXL_CMS_LIBRARY)
        target_link_libraries(dng_validate PRIVATE ${JXL_CMS_LIBRARY})
    endif()
    
    # Additional libraries that might be needed
    find_library(BROTLI_COMMON_LIBRARY NAMES brotlicommon)
    if(BROTLI_COMMON_LIBRARY)
        target_link_libraries(dng_validate PRIVATE ${BROTLI_COMMON_LIBRARY})
    endif()
    
    find_library(BROTLI_DEC_LIBRARY NAMES brotlidec)
    if(BROTLI_DEC_LIBRARY)
        target_link_libraries(dng_validate PRIVATE ${BROTLI_DEC_LIBRARY})
    endif()
    
    find_library(BROTLI_ENC_LIBRARY NAMES brotlienc)
    if(BROTLI_ENC_LIBRARY)
        target_link_libraries(dng_validate PRIVATE ${BROTLI_ENC_LIBRARY})
    endif()
    
    find_library(HWY_LIBRARY NAMES hwy)
    if(HWY_LIBRARY)
        target_link_libraries(dng_validate PRIVATE ${HWY_LIBRARY})
    endif()
    
    find_library(ZLIB_LIBRARY NAMES z)
    if(ZLIB_LIBRARY)
        target_link_libraries(dng_validate PRIVATE ${ZLIB_LIBRARY})
    endif()
    
    find_library(EXPAT_LIBRARY NAMES expat)
    if(EXPAT_LIBRARY)
        target_link_libraries(dng_validate PRIVATE ${EXPAT_LIBRARY})
    endif()
endif()

# Set output name
set_target_properties(dng_validate PROPERTIES
    OUTPUT_NAME dng_validate
)