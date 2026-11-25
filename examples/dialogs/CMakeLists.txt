find_package(Qt6 REQUIRED COMPONENTS QuickControls2)

# The Rask logo as the bundle icon (examples/assets/make-icon.swift).
set(example_icon "${CMAKE_CURRENT_SOURCE_DIR}/../assets/rask.icns")
set_source_files_properties(${example_icon} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

qt_add_executable(rask_dialogs_example main.cpp ${example_icon})

qt_add_qml_module(rask_dialogs_example
    URI RaskDialogsExample
    QML_FILES
        Main.qml
)

set_target_properties(rask_dialogs_example PROPERTIES
    OUTPUT_NAME "Rask Dialogs"
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_BUNDLE_NAME "Rask Dialogs"
    MACOSX_BUNDLE_ICON_FILE rask.icns
    MACOSX_BUNDLE_GUI_IDENTIFIER com.github.rask-project.rask.dialogs-example
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_COPYRIGHT "Copyright © 2026 Rask Project"
)

target_link_libraries(rask_dialogs_example
    PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
        Rask::Dialogs
        Rask::Platform
        Rask::Updater
)

rask_embed_libraries(rask_dialogs_example LIBRARIES Rask::Dialogs Rask::Platform Rask::Updater)

add_custom_command(TARGET rask_dialogs_example POST_BUILD
    COMMAND codesign --force --sign - "$<TARGET_BUNDLE_DIR:rask_dialogs_example>"
    COMMENT "Signing the dialogs example ad hoc"
    VERBATIM
)
