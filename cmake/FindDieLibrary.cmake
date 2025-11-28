include(FetchContent)

cmake_path(SET ROOT_DIR NORMALIZE "${CMAKE_CURRENT_LIST_DIR}/..")

# Only use Qt6

set(QT_BUILD_VERSION "6.7.3")

# TODO (calladoum) : here we oversimplify by assuming that compilation HOST and TARGET have same architecture

if(WIN32)
  # python -m aqt install-qt -O build windows desktop ${QT_BUILD_VERSION} win64_msvc2019_64
  set(QT_BUILD_COMPILER "msvc2019_64")

elseif(LINUX)
  if (${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "x86_64")
    # python -m aqt install-qt -O build linux desktop ${QT_BUILD_VERSION} linux_gcc_64 (x64)
    set(QT_BUILD_COMPILER "gcc_64")
  endif()

  if (${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL "aarch64")
    # python -m aqt install-qt -O build linux_arm desktop ${QT_BUILD_VERSION} linux_gcc_arm64 (arm64)
    set(QT_BUILD_COMPILER "gcc_arm64")
  endif()

elseif(APPLE)
  # python -m aqt install-qt -O build mac desktop ${QT_BUILD_VERSION} clang_64
  set(QT_BUILD_COMPILER "macos")
endif()

if(NOT QT_BUILD_COMPILER)
  message(FATAL_ERROR "Invalid Qt compiler setting")
else()
  message(STATUS "CMAKE_HOST_SYSTEM_PROCESSOR: ${CMAKE_HOST_SYSTEM_PROCESSOR}")
  message(STATUS "QT_BUILD_VERSION: ${QT_BUILD_VERSION}")
  message(STATUS "QT_BUILD_COMPILER: ${QT_BUILD_COMPILER}")
endif()

# Try to find Qt in multiple possible locations
# 1. Relative to current source directory (for local builds)
# 2. Relative to CMAKE_SOURCE_DIR (for source distribution builds)
# 3. From environment variable DIE_QT_ROOT (if set)

set(QT_SEARCH_PATHS
    "${ROOT_DIR}/build/${QT_BUILD_VERSION}/${QT_BUILD_COMPILER}/lib/cmake"
    "${CMAKE_SOURCE_DIR}/build/${QT_BUILD_VERSION}/${QT_BUILD_COMPILER}/lib/cmake"
)

if(DEFINED ENV{DIE_QT_ROOT})
    list(INSERT QT_SEARCH_PATHS 0 "$ENV{DIE_QT_ROOT}/${QT_BUILD_VERSION}/${QT_BUILD_COMPILER}/lib/cmake")
endif()

# Find Qt6Config.cmake
set(Qt6_CMAKE_ROOT "")
foreach(SEARCH_PATH ${QT_SEARCH_PATHS})
    # Normalize path to use forward slashes
    file(TO_CMAKE_PATH "${SEARCH_PATH}" NORMALIZED_PATH)
    if(EXISTS "${NORMALIZED_PATH}/Qt6/Qt6Config.cmake")
        set(Qt6_CMAKE_ROOT "${NORMALIZED_PATH}")
        break()
    endif()
endforeach()

if(NOT Qt6_CMAKE_ROOT)
    message(FATAL_ERROR "Could not find Qt6. Searched in:\n  ${QT_SEARCH_PATHS}\n\nPlease ensure Qt ${QT_BUILD_VERSION} is installed in the build directory or set DIE_QT_ROOT environment variable.")
endif()

# Normalize paths to avoid mixed slashes
file(TO_CMAKE_PATH "${Qt6_CMAKE_ROOT}/Qt6" Qt6_DIR)
set(QT_DIR ${Qt6_DIR})

message(STATUS "Qt6_CMAKE_ROOT: ${Qt6_CMAKE_ROOT}")
message(STATUS "Qt6_DIR: ${Qt6_DIR}")

list(INSERT CMAKE_MODULE_PATH 0
  ${Qt6_CMAKE_ROOT}
  ${Qt6_DIR}
)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Concurrent)

FetchContent_Declare(
  DieLibrary
  GIT_REPOSITORY "https://github.com/horsicq/die_library"
  GIT_TAG c8e482de7eac7d7f3621967cb3ac0d98f179b8cb
)

set(DIE_BUILD_AS_STATIC ON CACHE INTERNAL "")
FetchContent_MakeAvailable( DieLibrary )

message(STATUS "Using DieLibrary in '${dielibrary_SOURCE_DIR}'")

list(APPEND CMAKE_MODULE_PATH "${dielibrary_SOURCE_DIR}/dep/build_tools/cmake")
