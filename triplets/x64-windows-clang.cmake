# Community-style Windows triplet for this project.
# Ports are built with MSVC (default); the app uses clang-cl (ABI-compatible).
# Linkage matches Linux x64-linux-clang: static libraries + dynamic CRT.
include(${CMAKE_CURRENT_LIST_DIR}/configurations/windows-configuration.cmake)

set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
