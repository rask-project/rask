pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T

// A tooltip ("help tag") that looks like macOS's, for the QML style's
// ToolTip does not: a small rounded tag in its own window (the system draws
// its shadow and it may go past the window's edge), shown under the pointer
// after it rests on the parent, gone when the pointer leaves or presses.
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
                tip.close();
            }
        }
    }

    // Passive: the parent still gets the press.
    PointHandler {
        acceptedButtons: Qt.AllButtons
        onActiveChanged: {
            if (active) {
                showTimer.stop();
                tip.close();
            }
        }
    }

    Timer {
        id: showTimer

        interval: tag.delay
        onTriggered: {
            if (tag.text === "")
                return;
            tip.x = hover.point.position.x;
            tip.y = hover.point.position.y + 20;
            tip.open();
        }
    }

    onEnabledChanged: {
        if (!enabled)
            tip.close();
    }

    T.ToolTip {
        id: tip

        popupType: Popup.Window
        text: tag.text
        delay: 0
        timeout: 10000
        margins: 0
        topPadding: 4
        bottomPadding: 4
        leftPadding: 8
        rightPadding: 8
        implicitWidth: Math.min(implicitContentWidth + leftPadding + rightPadding, 360)
        implicitHeight: implicitContentHeight + topPadding + bottomPadding
        closePolicy: T.Popup.NoAutoClose

        enter: Transition {
            NumberAnimation {
                property: "opacity"
                to: 1
                duration: 0
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 120
            }
        }

        contentItem: Text {
            text: tip.text
            font.pixelSize: 11
            color: tag.dark ? Qt.rgba(1, 1, 1, 0.9) : Qt.rgba(0, 0, 0, 0.85)
            wrapMode: Text.Wrap
        }

        background: Rectangle {
            radius: 6
            color: tag.dark ? "#2c2c2e" : "#f6f6f6"
            border.width: 1
            border.color: tag.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.12)
        }
    }
}
