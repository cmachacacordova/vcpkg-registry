vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmachacacordova/i18n-redis
    REF 1.0.1-SNAPSHOT
    SHA512 a9fd7390f1dcb9d8cb6ec99f099c928a79d65975511cc65a9b6f541caa8e1a907fa3df08da120a6b246de492e5b71088375cd4d92061973d3eb58d92e8bdc306
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
