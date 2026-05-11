vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmachacacordova/i18n-redis
    REF v0.3.2
    SHA512 b00ace7f59d78262afd1b87639c466284659433a43cb823e9011894eaa3f95649b2474f3706c3f5ca55ae930d17c37f63427798a637118e8294f68f2d8b3301a
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/i18n-redis)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

