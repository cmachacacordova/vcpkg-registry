vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmachacacordova/i18n-redis
    REF 1.3.2-SNAPSHOT
    SHA512 af3455d0937ff50bba7d9de3e373cb4fd936fe49798245972852390e6015afb40a56ca0051e781115158fbce7da836974eac7df0ad351cb89e898690355a0a16
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
