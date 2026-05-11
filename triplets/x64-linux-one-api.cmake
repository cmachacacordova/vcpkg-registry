include(${CMAKE_CURRENT_LIST_DIR}/configurations/linux-configuration.cmake)

set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "")
set(VCPKG_CMAKE_C_COMPILER /opt/intel/oneapi/compiler/2026.0/bin/compiler/clang)
set(VCPKG_CMAKE_CXX_COMPILER /opt/intel/oneapi/compiler/2026.0/bin/compiler/clang++)
