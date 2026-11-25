# QML only: System Settings-style controls and the title-bar tab strip,
# drawn to match macOS (the strip's glass comes from Rask.Window).
rask_add_qml_module(Controls
    URI Rask.Controls
    QML_FILES
        FormGroup.qml
        FormRow.qml
        SearchBar.qml
        SidebarItem.qml
        SidebarLayout.qml
        TabStripButton.qml
        TabStrip.qml
    PUBLIC_LIBRARIES
        Qt6::Quick
        Qt6::QuickControls2
        Rask::Window
)
