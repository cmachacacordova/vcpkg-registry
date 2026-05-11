include(${CMAKE_CURRENT_LIST_DIR}/configurations/linux-configuration.cmake)

set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

set(VCPKG_FIXUP_ELF_RPATH ON)
