include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/zstd
    REF v1.3.3
    SHA512 72b63f96f65ca987cdc82c24354f7665c7dc3b2563cb0646f355c34bf8f090d8a0759729f8beaba8317272bdab34749f934055707b25cfd69c98a9fdcfbc59ae
    HEAD_REF dev)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(ZSTD_STATIC 1)
    set(ZSTD_SHARED 0)
else()
    set(ZSTD_STATIC 0)
    set(ZSTD_SHARED 1)
endif()

# Enable multithreaded mode. CMake build doesn't provide a multithreaded
# library target, but it is the default in Makefile and VS projects.
set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} /DZSTD_MULTITHREAD")
set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/build/cmake
    PREFER_NINJA
    OPTIONS
        -DZSTD_BUILD_SHARED=${ZSTD_SHARED}
        -DZSTD_BUILD_STATIC=${ZSTD_STATIC}
        -DZSTD_LEGACY_SUPPORT=1
        -DZSTD_BUILD_PROGRAMS=0
        -DZSTD_BUILD_TESTS=0
        -DZSTD_BUILD_CONTRIB=0)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    foreach(HEADER zdict.h zstd.h zstd_errors.h)
        file(READ ${CURRENT_PACKAGES_DIR}/include/${HEADER} HEADER_CONTENTS)
        string(REPLACE "defined(ZSTD_DLL_IMPORT) && (ZSTD_DLL_IMPORT==1)" "1" HEADER_CONTENTS "${HEADER_CONTENTS}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/include/${HEADER} "${HEADER_CONTENTS}")
    endforeach()
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/zstd)
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/zstd)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/zstd/copyright "ZSTD is dual licensed - see LICENSE and COPYING files\n")
