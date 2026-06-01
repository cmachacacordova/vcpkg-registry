vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cmachacacordova/i18n-redis
    REF 1.2.1-SNAPSHOT
    SHA512 3be5f43bf4138c6fb6c14f1e6f34bd22c6fc712f970597c72bb763b0d01564f37a5a9e96685c24922d2e8f5279d0eb83d5264868d7b5ed70c1ae1661a60b995e
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
