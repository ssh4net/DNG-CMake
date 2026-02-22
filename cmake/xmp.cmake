# XMP SDK Libraries

# Compute repository root relative to this CMake file (cmake -> repo root)
get_filename_component(REPO_ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)

# NOTE: Platform macros for consumers are exported via INTERFACE compile definitions
# (see XMP_TOOLKIT_INTERFACE_DEFINITIONS from the top-level CMakeLists.txt).

# Resolve the active XMP *_ENV macro once (WIN_ENV, MAC_ENV, IOS_ENV, ANDROID_ENV, WEB_ENV, UNIX_ENV).
set(XMP_TOOLKIT_ENV_DEFINITION "UNIX_ENV")
if(DEFINED XMP_TOOLKIT_INTERFACE_DEFINITIONS)
    foreach(_xmp_iface_def IN LISTS XMP_TOOLKIT_INTERFACE_DEFINITIONS)
        if(_xmp_iface_def MATCHES "_ENV$")
            set(XMP_TOOLKIT_ENV_DEFINITION "${_xmp_iface_def}")
            break()
        endif()
    endforeach()
endif()

# XMPCore Static Library
add_library(XMPCoreStatic STATIC
    # Core XMP source files
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/WXMPDocOps.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/WXMPIterator.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/WXMPMeta.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/WXMPUtils.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPDocOps-Utils.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPDocOps-Utils2.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPDocOps.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPDocOps2.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPIterator.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPIterator2.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPMeta-GetSet.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPMeta-Parse.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPMeta-Serialize.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPMeta.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPMeta2-GetSet.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPUtils-FileInfo.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPUtils.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPUtils2.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/ExpatAdapter.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/ParseRDF.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/XMPCore_Impl.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore/source/CoreObjectFactoryImpl.cpp
    
    # Additional core files
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/source/UnicodeConversions.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/source/XML_Node.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/source/XMP_LibUtils.cpp
    
    # ZUID support
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/third-party/zuid/sources/MD5.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/third-party/zuid/sources/ZUIDSysDep.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/third-party/zuid/sources/ZUIDUUID.cpp
)

# XMP core sources were authored for pre-C++17. Build them with C++14 to match VS projects.
set_target_properties(XMPCoreStatic PROPERTIES
    CXX_STANDARD 14
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
    DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}
)

if(DEFINED XMP_TOOLKIT_INTERFACE_DEFINITIONS)
    target_compile_definitions(XMPCoreStatic INTERFACE ${XMP_TOOLKIT_INTERFACE_DEFINITIONS})
endif()

# XMPCore definitions
target_compile_definitions(XMPCoreStatic PRIVATE
    XML_POOR_ENTROPY
    ${XMP_TOOLKIT_ENV_DEFINITION}
    _CRT_SECURE_NO_WARNINGS=1
    _SCL_SECURE_NO_WARNINGS=1
    NOMINMAX
    UNICODE
    _UNICODE
    AdobePrivate=1
    ENABLE_CPP_DOM_MODEL=0
    XML_STATIC=1
    HAVE_EXPAT_CONFIG_H=1
    XMP_StaticBuild=1
    BUILDING_XMPCORE_LIB=1
    XMP_COMPONENT_INT_NAMESPACE=AdobeXMPCore_Int
    BUILDING_XMPCORE_AS_STATIC=1
)

# Locate expat headers via CMAKE_PREFIX_PATH (e.g., E:/DVS). Make optional based on DNG_WITH_XMP
find_path(EXPAT_INCLUDE_DIR NAMES expat.h PATH_SUFFIXES include)
if(NOT EXPAT_INCLUDE_DIR)
    message(STATUS "expat.h not found via CMAKE_PREFIX_PATH; XMP build expects system expat. Ensure prefixes include expat headers if linking system expat.")
endif()

# XMPCore include directories
target_include_directories(XMPCoreStatic PRIVATE
    ${REPO_ROOT}/xmp/toolkit
    ${REPO_ROOT}/xmp/toolkit/public/include
)
if(EXPAT_INCLUDE_DIR)
    target_include_directories(XMPCoreStatic PRIVATE ${EXPAT_INCLUDE_DIR})
endif()

target_include_directories(XMPCoreStatic
    PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/xmp>
)

# Boost UUID headers: use the option from main CMakeLists.txt
if(XMP_USE_SYSTEM_BOOST)
    find_path(BOOST_UUID_INCLUDE_DIR NAMES boost/uuid/uuid.hpp PATH_SUFFIXES include)
    if(BOOST_UUID_INCLUDE_DIR)
        target_include_directories(XMPCoreStatic PRIVATE ${BOOST_UUID_INCLUDE_DIR})
        set(XMP_BOOST_INCLUDE_DIRS ${BOOST_UUID_INCLUDE_DIR})
    else()
        message(FATAL_ERROR "Boost UUID headers not found. Set CMAKE_PREFIX_PATH or disable XMP_USE_SYSTEM_BOOST to use vendored boost.")
    endif()
else()
    # Add both the third-party root (contains 'boost/') and boost dir explicitly
    target_include_directories(XMPCoreStatic PRIVATE
        ${REPO_ROOT}/xmp/toolkit/XMPCore/third-party
        ${REPO_ROOT}/xmp/toolkit/XMPCore/third-party/boost
    )
    set(XMP_BOOST_INCLUDE_DIRS
        ${REPO_ROOT}/xmp/toolkit/XMPCore/third-party
        ${REPO_ROOT}/xmp/toolkit/XMPCore/third-party/boost
    )
endif()

# XMPFiles Static Library
add_library(XMPFilesStatic STATIC
    # Core XMPFiles source files
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/WXMPFiles.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/XMPFiles.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/XMPFiles_Impl.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/HandlerRegistry.cpp
    
    # File Handlers
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/Basic_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/Generic_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/Trivial_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/Scanner_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/JPEG_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/TIFF_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/PNG_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/GIF_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/PSD_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/RIFF_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/WAVE_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/AIFF_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/MP3_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/MPEG2_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/MPEG4_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/ASF_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/FLV_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/SWF_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/InDesign_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/PostScript_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/SVG_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/WebP_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/UCF_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/HEIF_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/P2_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/SonyHDV_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/XDCAM_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/XDCAMEX_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/XDCAMFAM_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/XDCAMSAM_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/AVCHD_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/AVCUltra_Handler.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FileHandlers/CanonXF_Handler.cpp
    
    # Format Support
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/TIFF_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/TIFF_FileWriter.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/TIFF_MemoryReader.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/PNG_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/PSIR_FileWriter.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/PSIR_MemoryReader.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/IPTC_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/ReconcileIPTC.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/ReconcileLegacy.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/ReconcileTIFF.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/Reconcile_Impl.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/RIFF.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/RIFF_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/QuickTime_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/MOOV_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/ISOBaseMedia_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/ASF_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/AVCUltra_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/ID3_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/SWF_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/PostScript_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/SVG_Adapter.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/XMPScanner.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/META_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/P2_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/XDCAM_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/PackageFormat_Support.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/TimeConversionUtils.cpp
    
    # IFF Support
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/IFF/Chunk.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/IFF/ChunkController.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/IFF/ChunkPath.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/IFF/IChunkBehavior.cpp
    
    # WAVE Support
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/WAVE/WAVEBehavior.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/WAVE/WAVEReconcile.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/WAVE/BEXTMetadata.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/WAVE/CartMetadata.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/WAVE/Cr8rMetadata.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/WAVE/DISPMetadata.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/WAVE/INFOMetadata.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/WAVE/PrmlMetadata.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/WAVE/iXMLMetadata.cpp
    
    # AIFF Support
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/AIFF/AIFFBehavior.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/AIFF/AIFFMetadata.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/AIFF/AIFFReconcile.cpp
    
    # WebP Support
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/FormatSupport/WebP/WebPBehavior.cpp
    
    # Native Metadata Support
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/NativeMetadataSupport/IMetadata.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/NativeMetadataSupport/IReconcile.cpp
    ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles/source/NativeMetadataSupport/MetadataSet.cpp
    
    # Plugin Handler (OS-specific)
    ${REPO_ROOT}/xmp/toolkit/XMPFiles/source/PluginHandler/FileHandlerInstance.cpp
    ${REPO_ROOT}/xmp/toolkit/XMPFiles/source/PluginHandler/HostAPIImpl.cpp
    ${REPO_ROOT}/xmp/toolkit/XMPFiles/source/PluginHandler/Module.cpp
    $<$<BOOL:${WIN32}>:${REPO_ROOT}/xmp/toolkit/XMPFiles/source/PluginHandler/OS_Utils_WIN.cpp>
    $<$<NOT:$<BOOL:${WIN32}>>:${REPO_ROOT}/xmp/toolkit/XMPFiles/source/PluginHandler/OS_Utils_Linux.cpp>
    ${REPO_ROOT}/xmp/toolkit/XMPFiles/source/PluginHandler/PluginManager.cpp
    ${REPO_ROOT}/xmp/toolkit/XMPFiles/source/PluginHandler/XMPAtoms.cpp

    # Platform glue and IO utilities required by XMPFiles
    $<$<BOOL:${WIN32}>:${REPO_ROOT}/xmp/toolkit/source/Host_IO-Win.cpp>
    $<$<NOT:$<BOOL:${WIN32}>>:${REPO_ROOT}/xmp/toolkit/source/Host_IO-POSIX.cpp>
    ${REPO_ROOT}/xmp/toolkit/source/IOUtils.cpp
    ${REPO_ROOT}/xmp/toolkit/source/XIO.cpp
    ${REPO_ROOT}/xmp/toolkit/source/XMPFiles_IO.cpp
    ${REPO_ROOT}/xmp/toolkit/source/XMPStream_IO.cpp
    ${REPO_ROOT}/xmp/toolkit/source/XMP_ProgressTracker.cpp
    ${REPO_ROOT}/xmp/toolkit/source/SafeStringAPIs.cpp
    ${REPO_ROOT}/xmp/toolkit/source/PerfUtils.cpp
)
# Apply Boost include dirs to XMPFiles target after it's created
if(XMP_BOOST_INCLUDE_DIRS)
    target_include_directories(XMPFilesStatic PRIVATE ${XMP_BOOST_INCLUDE_DIRS})
endif()

# XMP files sources were authored for pre-C++17. Build them with C++14 to match VS projects.
set_target_properties(XMPFilesStatic PROPERTIES
    CXX_STANDARD 14
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
    DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX}
)

if(DEFINED XMP_TOOLKIT_INTERFACE_DEFINITIONS)
    target_compile_definitions(XMPFilesStatic INTERFACE ${XMP_TOOLKIT_INTERFACE_DEFINITIONS})
endif()

# Install XMP public headers (not part of export, installed separately)
# For static library builds, we only need the headers, not the .cpp/.incl_cpp template files
install(DIRECTORY ${REPO_ROOT}/xmp/toolkit/public/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/xmp
    FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
    PATTERN "source" EXCLUDE      # Exclude template implementation .cpp files
    PATTERN "client-glue" EXCLUDE # Exclude client glue code (not needed for static builds)
)

# XMPFiles definitions
target_compile_definitions(XMPFilesStatic PRIVATE
    XML_POOR_ENTROPY
    ${XMP_TOOLKIT_ENV_DEFINITION}
    _CRT_SECURE_NO_WARNINGS=1
    _SCL_SECURE_NO_WARNINGS=1
    NOMINMAX
    UNICODE
    _UNICODE
    AdobePrivate=1
    ENABLE_CPP_DOM_MODEL=0
    XML_STATIC=1
    HAVE_EXPAT_CONFIG_H=1
    XMP_StaticBuild=1
    BUILDING_XMPFILES_LIB=1
    XMP_COMPONENT_INT_NAMESPACE=AdobeXMPFiles_Int
    BUILDING_XMPFILES_AS_STATIC=1
)

# XMPFiles include directories
target_include_directories(XMPFilesStatic PRIVATE
    ${REPO_ROOT}/xmp/toolkit
    ${REPO_ROOT}/xmp/toolkit/public/include
    ${REPO_ROOT}/xmp/toolkit/public/include/client-glue
    ${REPO_ROOT}/xmp/toolkit/XMPFilesPlugins/api/source
)
if(EXPAT_INCLUDE_DIR)
    target_include_directories(XMPFilesStatic PRIVATE ${EXPAT_INCLUDE_DIR})
endif()

target_include_directories(XMPFilesStatic
    PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/xmp>
)

# Link XMPFiles with XMPCore
target_link_libraries(XMPFilesStatic PUBLIC
    XMPCoreStatic
)

# Link with system libraries
# Use PUBLIC for static libraries so downstream projects get transitive dependencies
find_package(EXPAT)
if(EXPAT_FOUND)
    target_link_libraries(XMPCoreStatic PUBLIC EXPAT::EXPAT)
else()
    # Fallback to manual library finding
    if(WIN32)
        find_library(EXPAT_LIBRARY_RELEASE NAMES libexpatMT libexpatMD libexpat expat)
        find_library(EXPAT_LIBRARY_DEBUG   NAMES libexpatdMT libexpatdMD libexpatd expatd)
        if(EXPAT_LIBRARY_RELEASE AND EXPAT_LIBRARY_DEBUG)
            target_link_libraries(XMPCoreStatic PUBLIC 
                $<$<CONFIG:Debug>:${EXPAT_LIBRARY_DEBUG}>
                $<$<NOT:$<CONFIG:Debug>>:${EXPAT_LIBRARY_RELEASE}>
            )
        elseif(EXPAT_LIBRARY_RELEASE)
            target_link_libraries(XMPCoreStatic PUBLIC ${EXPAT_LIBRARY_RELEASE})
        elseif(EXPAT_LIBRARY_DEBUG)
            target_link_libraries(XMPCoreStatic PUBLIC ${EXPAT_LIBRARY_DEBUG})
        endif()
    else()
        find_library(EXPAT_LIBRARY NAMES expat REQUIRED)
        target_link_libraries(XMPCoreStatic PUBLIC ${EXPAT_LIBRARY})
    endif()
endif()

find_package(ZLIB)
if(ZLIB_FOUND)
    target_link_libraries(XMPCoreStatic PUBLIC ZLIB::ZLIB)
else()
    # Fallback to manual library finding
    if(WIN32)
        find_library(ZLIB_LIBRARY_RELEASE NAMES zlib zlibstatic z)
        find_library(ZLIB_LIBRARY_DEBUG   NAMES zlibd zlibstaticd zd)
        if(ZLIB_LIBRARY_RELEASE AND ZLIB_LIBRARY_DEBUG)
            target_link_libraries(XMPCoreStatic PUBLIC 
                $<$<CONFIG:Debug>:${ZLIB_LIBRARY_DEBUG}>
                $<$<NOT:$<CONFIG:Debug>>:${ZLIB_LIBRARY_RELEASE}>
            )
        elseif(ZLIB_LIBRARY_RELEASE)
            target_link_libraries(XMPCoreStatic PUBLIC ${ZLIB_LIBRARY_RELEASE})
        elseif(ZLIB_LIBRARY_DEBUG)
            target_link_libraries(XMPCoreStatic PUBLIC ${ZLIB_LIBRARY_DEBUG})
        endif()
    else()
        find_library(ZLIB_LIBRARY NAMES z REQUIRED)
        target_link_libraries(XMPCoreStatic PUBLIC ${ZLIB_LIBRARY})
    endif()
endif()
