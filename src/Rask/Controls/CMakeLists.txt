# QML only: System Settings-style controls drawn to match macOS.
rask_add_qml_module(Controls
    URI Rask.Controls
    QML_FILES
        FormGroup.qml
        FormRow.qml
        SidebarItem.qml
        SidebarLayout.qml
    RESOURCES
        icons/appearance.svg
        icons/keyboard.svg
        icons/security.svg
        icons/updates.svg
        icons/window.svg
    PUBLIC_LIBRARIES
        Qt6::Quick
        Qt6::QuickControls2
        # The badges are SVGs: apps deploy Qt's SVG image format with it.
        Qt6::Svg
)
