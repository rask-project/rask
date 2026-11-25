find_package(Qt6 REQUIRED COMPONENTS QuickControls2)

qt_add_executable(rask_dialogs_example main.cpp)

qt_add_qml_module(rask_dialogs_example
    URI RaskDialogsExample
    QML_FILES
        Main.qml
)

set_target_properties(rask_dialogs_example PROPERTIES
    OUTPUT_NAME "Rask Dialogs"
    MACOSX_BUNDLE TRUE
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
        Rask::Updater
)

rask_embed_libraries(rask_dialogs_example LIBRARIES Rask::Dialogs Rask::Updater)

if(APPLE)
    add_custom_command(TARGET rask_dialogs_example POST_BUILD
        COMMAND codesign --force --sign - "$<TARGET_BUNDLE_DIR:rask_dialogs_example>"
        COMMENT "Signing the dialogs example ad hoc"
        VERBATIM
    )
endif()
