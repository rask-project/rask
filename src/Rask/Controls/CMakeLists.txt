# QML only: System Settings-style controls, the title-bar tab strip and
# toolbar buttons, drawn to match macOS (their glass comes from Rask.Window).
rask_add_qml_module(Controls
    URI Rask.Controls
    QML_FILES
        FormGroup.qml
        FormRow.qml
        HelpTag.qml
        SearchBar.qml
        SidebarItem.qml
        SidebarLayout.qml
        TabStripButton.qml
        TabStrip.qml
        ToolbarButton.qml
        ToolbarGroup.qml
    PUBLIC_LIBRARIES
        Qt6::Quick
        Qt6::QuickControls2
        Rask::Window
)
