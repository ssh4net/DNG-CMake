# Doxygen documentation generation for DNG SDK and XMP Toolkit
#
# This module provides optional documentation generation using Doxygen.
# It creates targets for generating HTML documentation that can be installed.

if(NOT BUILD_DOCUMENTATION)
    return()
endif()

# Find Doxygen executable
find_package(Doxygen QUIET)

if(NOT DOXYGEN_FOUND)
    message(STATUS "Doxygen not found. Documentation generation disabled.")
    message(STATUS "Install Doxygen to enable documentation: https://www.doxygen.nl/download.html")
    return()
endif()

message(STATUS "Doxygen found: ${DOXYGEN_EXECUTABLE} (version ${DOXYGEN_VERSION})")

# Check for dot (Graphviz) for generating diagrams
if(DOXYGEN_DOT_FOUND)
    message(STATUS "Graphviz dot found: ${DOXYGEN_DOT_EXECUTABLE}")
    set(DOXYGEN_HAVE_DOT "YES")
else()
    message(STATUS "Graphviz dot not found. Documentation will be generated without diagrams.")
    set(DOXYGEN_HAVE_DOT "NO")
endif()

#---------------------------------------------------------------------------
# DNG SDK Documentation
#---------------------------------------------------------------------------

set(DNG_DOXYFILE_IN ${CMAKE_SOURCE_DIR}/cmake/doxygen.cfg.in)
set(DNG_DOXYFILE_OUT ${CMAKE_CURRENT_BINARY_DIR}/dng_sdk/Doxyfile)
set(DOXYGEN_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/docs/dng_sdk)
set(DNG_DOXYGEN_OUTPUT_DIR ${DOXYGEN_OUTPUT_DIR})

# Configure Doxyfile for DNG SDK
configure_file(${DNG_DOXYFILE_IN} ${DNG_DOXYFILE_OUT} @ONLY)

# Define output file that acts as a timestamp for documentation generation
set(DNG_DOCS_STAMP_FILE ${DNG_DOXYGEN_OUTPUT_DIR}/html/index.html)

# Create custom command that generates documentation
# This tracks dependencies and only regenerates when inputs change
add_custom_command(
    OUTPUT ${DNG_DOCS_STAMP_FILE}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${DNG_DOXYGEN_OUTPUT_DIR}
    COMMAND ${DOXYGEN_EXECUTABLE} ${DNG_DOXYFILE_OUT}
    COMMAND ${CMAKE_COMMAND} -E touch ${DNG_DOCS_STAMP_FILE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${DNG_DOXYFILE_OUT}
    COMMENT "Generating DNG SDK documentation with Doxygen"
    VERBATIM
)

# Create target that depends on the output file
# ALL keyword ensures it's built with the default target
add_custom_target(dng_sdk_docs ALL
    DEPENDS ${DNG_DOCS_STAMP_FILE}
)

# Install DNG SDK documentation (part of default install, not a separate component)
# CMake will check if the output exists and skip regeneration during install
# Install to share/doc/dng_sdk (Unix) or doc/dng_sdk (Windows)
if(WIN32)
    set(DNG_INSTALL_DIR "doc/dng_sdk")
else()
    set(DNG_INSTALL_DIR "share/doc/dng_sdk")
endif()
install(DIRECTORY ${DNG_DOXYGEN_OUTPUT_DIR}/html/
    DESTINATION ${DNG_INSTALL_DIR}
    OPTIONAL
)

#---------------------------------------------------------------------------
# XMP Toolkit Documentation
#---------------------------------------------------------------------------

if(DNG_WITH_XMP)
    set(XMP_DOXYFILE ${CMAKE_SOURCE_DIR}/xmp/toolkit/build/Doxyfile)
    set(XMP_DOXYGEN_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/docs/xmp)

    # Check if XMP Doxyfile exists
    if(EXISTS ${XMP_DOXYFILE})
        # Create a modified Doxyfile for XMP with updated paths
        set(XMP_DOXYFILE_OUT ${CMAKE_CURRENT_BINARY_DIR}/xmp/Doxyfile)

        # Read the original Doxyfile
        file(READ ${XMP_DOXYFILE} XMP_DOXYFILE_CONTENT)

        # Update OUTPUT_DIRECTORY to point to our build directory
        string(REGEX REPLACE "OUTPUT_DIRECTORY[ \t]*=[ \t]*[^\n]*"
               "OUTPUT_DIRECTORY       = ${XMP_DOXYGEN_OUTPUT_DIR}"
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")

        # Update HTML_OUTPUT to just "html"
        string(REGEX REPLACE "HTML_OUTPUT[ \t]*=[ \t]*[^\n]*"
               "HTML_OUTPUT            = html"
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")

        # Update PROJECT_NUMBER with version
        string(REGEX REPLACE "PROJECT_NUMBER[ \t]*=[ \t]*[^\n]*"
               "PROJECT_NUMBER         = ${PROJECT_VERSION}"
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")

        # Fix INPUT paths - the original references non-existent ../../documents/toolkit
        # Document all XMP toolkit directories except third-party
        string(REGEX REPLACE "INPUT[ \t]*=[ \t]*[^\n]*(\n[ \t]*[^\n]+)*"
               "INPUT                  = ${CMAKE_SOURCE_DIR}/xmp/toolkit/public \\\\\n                         ${CMAKE_SOURCE_DIR}/xmp/toolkit/source \\\\\n                         ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCommon \\\\\n                         ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCompareAndMerge \\\\\n                         ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPCore \\\\\n                         ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPExtensions \\\\\n                         ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFiles \\\\\n                         ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPFilesPlugins \\\\\n                         ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPScript \\\\\n                         ${CMAKE_SOURCE_DIR}/xmp/toolkit/XMPWasm"
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")

        # Enable RECURSIVE to scan all subdirectories
        string(REGEX REPLACE "RECURSIVE[ \t]*=[ \t]*NO"
               "RECURSIVE              = YES"
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")

        # Enable documentation features to match DNG SDK quality
        string(REGEX REPLACE "EXTRACT_ALL[ \t]*=[ \t]*NO"
               "EXTRACT_ALL            = YES"
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "SOURCE_BROWSER[ \t]*=[ \t]*NO"
               "SOURCE_BROWSER         = YES"
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "GENERATE_TREEVIEW[ \t]*=[ \t]*NONE"
               "GENERATE_TREEVIEW      = YES"
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "SEARCHENGINE[ \t]*=[ \t]*NO"
               "SEARCHENGINE           = YES"
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")

        # Enable macro expansion to handle XMP's heavy use of BASE_CLASS and other macros
        string(REGEX REPLACE "MACRO_EXPANSION[ \t]*=[ \t]*NO"
               "MACRO_EXPANSION        = YES"
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "EXPAND_ONLY_PREDEF[ \t]*=[ \t]*NO"
               "EXPAND_ONLY_PREDEF     = YES"
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")

        # Remove obsolete HTML_HEADER, HTML_FOOTER, HTML_STYLESHEET that reference missing files
        string(REGEX REPLACE "HTML_HEADER[ \t]*=[ \t]*[^\n]*"
               "HTML_HEADER            ="
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "HTML_FOOTER[ \t]*=[ \t]*[^\n]*"
               "HTML_FOOTER            ="
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "HTML_STYLESHEET[ \t]*=[ \t]*[^\n]*"
               "HTML_STYLESHEET        ="
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")

        # Remove obsolete tags for newer Doxygen versions
        string(REGEX REPLACE "SYMBOL_CACHE_SIZE[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "SHOW_DIRECTORIES[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "COLS_IN_ALPHA_INDEX[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "HTML_TIMESTAMP[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "HTML_ALIGN_MEMBERS[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "USE_INLINE_TREES[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "LATEX_SOURCE_CODE[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "XML_SCHEMA[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "XML_DTD[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "PERL_PATH[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "CLASS_DIAGRAMS[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "MSCGEN_PATH[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "DOT_FONTNAME[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "DOT_FONTSIZE[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")
        string(REGEX REPLACE "DOT_TRANSPARENT[ \t]*=[ \t]*[^\n]*\n" "" XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")

        # Fix PAPER_TYPE from a4wide to a4
        string(REGEX REPLACE "PAPER_TYPE[ \t]*=[ \t]*a4wide"
               "PAPER_TYPE             = a4"
               XMP_DOXYFILE_CONTENT "${XMP_DOXYFILE_CONTENT}")

        # Write modified Doxyfile
        file(WRITE ${XMP_DOXYFILE_OUT} "${XMP_DOXYFILE_CONTENT}")

        # Define output file that acts as a timestamp for documentation generation
        set(XMP_DOCS_STAMP_FILE ${XMP_DOXYGEN_OUTPUT_DIR}/html/index.html)

        # Create custom command that generates documentation
        # This tracks dependencies and only regenerates when inputs change
        add_custom_command(
            OUTPUT ${XMP_DOCS_STAMP_FILE}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${XMP_DOXYGEN_OUTPUT_DIR}
            COMMAND ${DOXYGEN_EXECUTABLE} ${XMP_DOXYFILE_OUT}
            COMMAND ${CMAKE_COMMAND} -E touch ${XMP_DOCS_STAMP_FILE}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/xmp/toolkit/build
            DEPENDS ${XMP_DOXYFILE_OUT}
            COMMENT "Generating XMP Toolkit documentation with Doxygen"
            VERBATIM
        )

        # Create target that depends on the output file
        # ALL keyword ensures it's built with the default target
        add_custom_target(xmp_docs ALL
            DEPENDS ${XMP_DOCS_STAMP_FILE}
        )

        # Install XMP documentation (part of default install, not a separate component)
        # CMake will check if the output exists and skip regeneration during install
        # Install to share/doc/xmp (Unix) or doc/xmp (Windows), under doc directory
        if(WIN32)
            set(XMP_INSTALL_DIR "doc/xmp")
        else()
            set(XMP_INSTALL_DIR "share/doc/xmp")
        endif()
        install(DIRECTORY ${XMP_DOXYGEN_OUTPUT_DIR}/html/
            DESTINATION ${XMP_INSTALL_DIR}
            OPTIONAL
        )

        message(STATUS "XMP Toolkit documentation generation enabled")
    else()
        message(STATUS "XMP Doxyfile not found at ${XMP_DOXYFILE}")
    endif()
endif()

#---------------------------------------------------------------------------
# Combined Documentation Target
#---------------------------------------------------------------------------

# Create a top-level target that generates all documentation
# ALL keyword ensures it's built with the default target
if(TARGET xmp_docs)
    add_custom_target(docs ALL
        DEPENDS dng_sdk_docs xmp_docs
        COMMENT "Generating all documentation (DNG SDK + XMP Toolkit)"
    )
else()
    add_custom_target(docs ALL
        DEPENDS dng_sdk_docs
        COMMENT "Generating DNG SDK documentation"
    )
endif()

message(STATUS "Documentation generation enabled:")
message(STATUS "  - Documentation will be built automatically during build")
message(STATUS "  - Documentation will be installed automatically with 'cmake --install .'")
message(STATUS "  - Manual build: cmake --build . --target docs")
if(WIN32)
    message(STATUS "  - DNG SDK install location: ${CMAKE_INSTALL_PREFIX}/doc/dng_sdk")
    if(TARGET xmp_docs)
        message(STATUS "  - XMP Toolkit install location: ${CMAKE_INSTALL_PREFIX}/doc/xmp")
    endif()
else()
    message(STATUS "  - DNG SDK install location: ${CMAKE_INSTALL_PREFIX}/share/doc/dng_sdk")
    if(TARGET xmp_docs)
        message(STATUS "  - XMP Toolkit install location: ${CMAKE_INSTALL_PREFIX}/share/doc/xmp")
    endif()
endif()
