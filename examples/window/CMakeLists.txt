find_package(Qt6 REQUIRED COMPONENTS QuickControls2)

qt_add_executable(rask_window_example main.cpp)

qt_add_qml_module(rask_window_example
    URI RaskWindowExample
    QML_FILES
        Main.qml
)

set_target_properties(rask_window_example PROPERTIES
    OUTPUT_NAME "Rask Window"
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_GUI_IDENTIFIER com.github.rask-project.rask.window-example
)

target_link_libraries(rask_window_example
    PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
        Rask::Platform
        Rask::Window
)

rask_embed_libraries(rask_window_example LIBRARIES Rask::Platform Rask::Window)

add_custom_command(TARGET rask_window_example POST_BUILD
    COMMAND codesign --force --sign - "$<TARGET_BUNDLE_DIR:rask_window_example>"
    COMMENT "Signing the window example ad hoc"
    VERBATIM
)
