vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmachacacordova/i18n-redis
    REF v0.3.1
    SHA512 458c5c06cbe47e3342f32e68a26bff07f8d1cb0209c3e6a720ac7e4085750c2ce447612555eff4029941af9a1c106387a937cfb2d852ed60fbb889e0836b5441
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/i18n-redis)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

