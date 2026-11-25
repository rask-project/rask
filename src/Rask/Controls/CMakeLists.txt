# QML only: System Settings-style controls drawn to match macOS.
rask_add_qml_module(Controls
    URI Rask.Controls
    QML_FILES
        FormGroup.qml
        FormRow.qml
        SidebarItem.qml
        SidebarLayout.qml
    PUBLIC_LIBRARIES
        Qt6::Quick
        Qt6::QuickControls2
)
