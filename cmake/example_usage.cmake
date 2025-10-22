# Example CMakeLists.txt for downstream projects using installed dng_sdk
# This file demonstrates how to use the installed dng_sdk package

cmake_minimum_required(VERSION 3.16)
project(my_dng_application)

# Method 1: Using CMake's find_package()
# This will find dng_sdk-config.cmake in CMAKE_PREFIX_PATH
find_package(dng_sdk 1.7 REQUIRED)

# Optionally find XMP Toolkit separately if you need it standalone
# find_package(XMPToolkit 1.7 REQUIRED)

# Create your executable
add_executable(my_app main.cpp)

# Link against dng_sdk
# The dng_sdk::dng_sdk target includes all necessary dependencies
target_link_libraries(my_app PRIVATE dng_sdk::dng_sdk)

# If you need to use XMP Toolkit independently:
# target_link_libraries(my_app PRIVATE XMP::XMPCore XMP::XMPFiles)

# The include directories are automatically added via the imported targets

# ============================================================================
# Method 2: Using pkg-config
# ============================================================================
# find_package(PkgConfig REQUIRED)
#
# pkg_check_modules(DNG_SDK REQUIRED IMPORTED_TARGET dng_sdk)
#
# add_executable(my_app main.cpp)
# target_link_libraries(my_app PRIVATE PkgConfig::DNG_SDK)
#
# For XMP Toolkit only:
# pkg_check_modules(XMP REQUIRED IMPORTED_TARGET XMPToolkit)
# target_link_libraries(my_app PRIVATE PkgConfig::XMP)

# ============================================================================
# Usage Notes:
# ============================================================================
#
# 1. Install dng_sdk first:
#    mkdir build && cd build
#    cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..
#    cmake --build .
#    sudo cmake --install .
#
# 2. Build your application:
#    mkdir build && cd build
#    cmake -DCMAKE_PREFIX_PATH=/usr/local ..
#    cmake --build .
#
# 3. Or use pkg-config:
#    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
#    pkg-config --cflags --libs dng_sdk
