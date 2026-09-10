vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nickelpro/cNBT
    REF 000ce9405be86da0ddefff60bc28ecf10a80df70
    SHA512 795a9480735ab632791611729ba8d7d0f0f5ad5ceaee67399c3c97fed301c2c6d194c855ff9ac064bed896512de219c03a809ef15abca2097766be3977394396
    HEAD_REF master
    PATCHES
        0001-cmake-export-and-install.patch
        0002-msvc-vla-fix.patch
        0003-msvc-restrict-fix.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCNBT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME cnbt)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
