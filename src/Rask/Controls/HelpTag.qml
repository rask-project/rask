pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window

// A tooltip ("help tag") that looks like macOS's, for the QML style's
// ToolTip does not: a small rounded tag in a transparent window of its own
// (the system draws its shadow; it may go past the window's edge), shown
// under the pointer after it rests on the parent, gone when the pointer
// leaves or presses.
// Put it inside the control it explains:
//
//     ToolButton { HelpTag { text: qsTr("Split Side by Side") } }
Item {
    id: tag

    property string text
    // How long the pointer rests before the tag shows, as AppKit's.
    property int delay: 1000

    readonly property bool dark: Application.styleHints.colorScheme === Qt.ColorScheme.Dark

    anchors.fill: parent

    HoverHandler {
        id: hover

        onHoveredChanged: {
            if (hovered) {
                showTimer.restart();
            } else {
                showTimer.stop();
                tip.visible = false;
            }
        }
    }

    // Passive: the parent still gets the press.
    PointHandler {
        acceptedButtons: Qt.AllButtons
        onActiveChanged: {
            if (active) {
                showTimer.stop();
                tip.visible = false;
            }
        }
    }

    Timer {
        id: showTimer

        interval: tag.delay
        onTriggered: {
            if (tag.text === "")
                return;
            const point = tag.mapToGlobal(hover.point.position.x, hover.point.position.y);
            tip.x = point.x;
            tip.y = point.y + 20;
            tip.visible = true;
        }
    }

    onEnabledChanged: {
        if (!enabled)
            tip.visible = false;
    }

    // Transparent around the rounded tag: the system's shadow follows its shape.
    Window {
        id: tip

        transientParent: tag.Window.window
        flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowTransparentForInput | Qt.WindowDoesNotAcceptFocus
        color: "transparent"
        width: bubble.width
        height: bubble.height
        visible: false

        Rectangle {
            id: bubble

            width: label.width + 16
            height: label.implicitHeight + 8
            radius: 6
            color: tag.dark ? "#2c2c2e" : "#f6f6f6"
            border.width: 1
            border.color: tag.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.12)

            Text {
                id: label

                x: 8
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, 480)
                text: tag.text
                font.pixelSize: 11
                color: tag.dark ? Qt.rgba(1, 1, 1, 0.9) : Qt.rgba(0, 0, 0, 0.85)
                elide: Text.ElideMiddle
            }
        }
    }
}
