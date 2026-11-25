find_package(Qt6 REQUIRED COMPONENTS QuickControls2)

# The Rask logo as the bundle icon (examples/assets/make-icon.swift).
set(example_icon "${CMAKE_CURRENT_SOURCE_DIR}/../assets/rask.icns")
set_source_files_properties(${example_icon} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

qt_add_executable(rask_documents_example main.cpp ${example_icon})

qt_add_qml_module(rask_documents_example
    URI RaskDocumentsExample
    QML_FILES
        Main.qml
)

set_target_properties(rask_documents_example PROPERTIES
    # Text documents, so the Finder offers it in "Open With".
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist.in"
    OUTPUT_NAME "Rask Documents"
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_BUNDLE_NAME "Rask Documents"
    MACOSX_BUNDLE_ICON_FILE rask.icns
    MACOSX_BUNDLE_GUI_IDENTIFIER com.github.rask-project.rask.documents-example
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_COPYRIGHT "Copyright © 2026 Rask Project"
)

target_link_libraries(rask_documents_example
    PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
        Rask::Application
        Rask::Controls
        Rask::Dialogs
        Rask::Platform
        Rask::Window
)

rask_embed_libraries(rask_documents_example LIBRARIES Rask::Application Rask::Controls Rask::Dialogs Rask::Platform Rask::Window)

add_custom_command(TARGET rask_documents_example POST_BUILD
    COMMAND codesign --force --sign - "$<TARGET_BUNDLE_DIR:rask_documents_example>"
    COMMENT "Signing the documents example ad hoc"
    VERBATIM
)
