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

# Platform-specific system libraries (not already provided by dng_sdk)
if(WIN32)
    # Only link system libraries that are not already provided by dng_sdk
    # dng_sdk already provides: JPEG, JXL, HWY, Brotli, ZLIB, EXPAT via PUBLIC linkage
    
    # Additional Windows-specific libraries
    target_link_libraries(dng_validate PRIVATE
        kernel32
        user32
        gdi32
        winspool
        shell32
        ole32
        oleaut32
        uuid
        comdlg32
        advapi32
    )
elseif(UNIX AND NOT APPLE)
    target_link_libraries(dng_validate PRIVATE
        dl
        rt
        m
    )
endif()

# Set output name
set_target_properties(dng_validate PROPERTIES
    OUTPUT_NAME dng_validate
)
