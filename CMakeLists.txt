cmake_minimum_required(VERSION 3.21.1)

project(Rask VERSION 0.1.0 LANGUAGES CXX)
if(APPLE)
    enable_language(OBJCXX)
endif()

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.10 REQUIRED COMPONENTS Core Gui Qml Quick QmlIntegration)

qt_standard_project_setup(REQUIRES 6.10)

include(GNUInstallDirs)
include(GenerateExportHeader)
include(CMakePackageConfigHelpers)
include(cmake/RaskModule.cmake)
include(cmake/RaskApp.cmake)

# Every module's qmldir, .qmltypes and plugin end up in qml/Rask/<Module>/.
set(QT_QML_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/qml")

add_subdirectory(src/Rask/Platform)
add_subdirectory(src/Rask/Window)
add_subdirectory(src/Rask/Dialogs)
add_subdirectory(src/Rask/Updater)

option(RASK_BUILD_EXAMPLES "Build the rask examples" ${PROJECT_IS_TOP_LEVEL})
option(RASK_BUILD_TESTS "Build the rask tests" ${PROJECT_IS_TOP_LEVEL})

if(RASK_BUILD_EXAMPLES)
    add_subdirectory(examples/window)
    add_subdirectory(examples/dialogs)
endif()

if(RASK_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# find_package(Rask) against an installed copy.
install(EXPORT RaskTargets
    NAMESPACE Rask::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Rask
)
configure_package_config_file(cmake/RaskConfig.cmake.in
    "${PROJECT_BINARY_DIR}/RaskConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Rask
)
write_basic_package_version_file("${PROJECT_BINARY_DIR}/RaskConfigVersion.cmake"
    COMPATIBILITY SameMajorVersion
)
install(FILES
    "${PROJECT_BINARY_DIR}/RaskConfig.cmake"
    "${PROJECT_BINARY_DIR}/RaskConfigVersion.cmake"
    cmake/RaskApp.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/Rask
)
