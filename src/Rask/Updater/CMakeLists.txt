rask_add_qml_module(Updater
    URI Rask.Updater
    PUBLIC_HEADERS
        Updater.h
    SOURCES
        Updater.cpp
        UpdaterNative_p.h
        UpdaterNative.mm
    PUBLIC_LIBRARIES
        Qt6::Qml
    LIBRARIES
        "-framework AppKit"
)

include("${PROJECT_SOURCE_DIR}/cmake/RaskSparkle.cmake")
get_filename_component(sparkle_framework_dir "${SPARKLE_FRAMEWORK}" DIRECTORY)
# -iframework: a system framework path, so its headers raise no warnings.
target_compile_options(rask_updater PRIVATE "-iframework${sparkle_framework_dir}")
target_link_options(rask_updater PRIVATE "-F${sparkle_framework_dir}")
target_link_libraries(rask_updater PRIVATE "-framework Sparkle")
# Tests and tools run from the build tree find Sparkle next to it; apps
# embed it in Contents/Frameworks (rask_embed_libraries()).
set_property(TARGET rask_updater APPEND PROPERTY BUILD_RPATH "${sparkle_framework_dir}")
set_target_properties(rask_updater PROPERTIES RASK_EMBED_FRAMEWORKS "${SPARKLE_FRAMEWORK}")

install(DIRECTORY "${SPARKLE_FRAMEWORK}" DESTINATION ${CMAKE_INSTALL_LIBDIR} USE_SOURCE_PERMISSIONS)
