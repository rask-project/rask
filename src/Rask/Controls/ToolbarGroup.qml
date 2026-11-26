pragma ComponentBehavior: Bound

import QtQuick

import Rask.Window

// A capsule of ToolbarButtons in the title bar, as in Xcode's toolbar (back
// and forward, run and stop): native Liquid Glass where the system has it,
// else the same look drawn in QML. While the pointer is over it the window
// does not move with a drag, so the buttons take their presses.
Item {
    id: group

    // The window's NativeWindow, kept from moving while the pointer is here.
    property NativeWindow nativeWindow: null
    default property alias buttons: row.data

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    GlassEffect {
        id: glass

        anchors.fill: parent
        visible: supported
        cornerRadius: height / 2
    }

    GlassSurface {
        anchors.fill: parent
        visible: !glass.supported
    }

    HoverHandler {
        onHoveredChanged: {
            if (group.nativeWindow)
                group.nativeWindow.movable = !hovered;
        }
    }

    Row {
        id: row

        anchors.fill: parent
    }
}
