find_package(Qt6 REQUIRED COMPONENTS QuickControls2)

qt_add_executable(rask_settings_example main.cpp)

qt_add_qml_module(rask_settings_example
    URI RaskSettingsExample
    QML_FILES
        Main.qml
)

set_target_properties(rask_settings_example PROPERTIES
    OUTPUT_NAME "Rask Settings"
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_GUI_IDENTIFIER com.github.rask-project.rask.settings-example
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_COPYRIGHT "Copyright © 2026 Rask Project"
)

target_link_libraries(rask_settings_example
    PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
        Rask::Controls
        Rask::Platform
        Rask::Updater
        Rask::Window
)

rask_embed_libraries(rask_settings_example LIBRARIES Rask::Controls Rask::Platform Rask::Updater Rask::Window)

if(APPLE)
    add_custom_command(TARGET rask_settings_example POST_BUILD
        COMMAND codesign --force --sign - "$<TARGET_BUNDLE_DIR:rask_settings_example>"
        COMMENT "Signing the settings example ad hoc"
        VERBATIM
    )
endif()
