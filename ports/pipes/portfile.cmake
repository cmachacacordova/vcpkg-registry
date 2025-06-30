vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO joboccara/pipes
    REF v1.0.0
    SHA512 387e186dc8e45fb6045cd8ba2a3c0fd6f455ae764756a0b1438c1cf626fffc8ce484839ce3f57c05b529f346c91e26839fac8381a90342d0a2760550d042b6d5
    HEAD_REF master
)

# Build only the release configuration since this is a header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/pipes/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME README.md)
