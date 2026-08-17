vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmachacacordova/i18n-redis
    REF 1.3.4-RELEASE
    SHA512 a30d49d5c7cd91d5a1e242b5e79568988c956fd1e345255d65f126fbf1e5a8bbecec86d6438e7f7071e83d8cddf738cfe698bfa7f6ffbec2b886181a781489a6
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        simdjson I18N_REDIS_USE_SIMDJSON
        yyjson   I18N_REDIS_USE_YYJSON
)

if("simdjson" IN_LIST FEATURES)
    set(I18N_REDIS_JSON_BACKEND "simdjson")
elseif("yyjson" IN_LIST FEATURES)
    set(I18N_REDIS_JSON_BACKEND "yyjson")
else()
    set(I18N_REDIS_JSON_BACKEND "simdjson")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DI18N_REDIS_JSON_BACKEND=${I18N_REDIS_JSON_BACKEND}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/i18n-redis)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
