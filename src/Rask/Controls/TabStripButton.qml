pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T

import Rask.Window

// A pill-shaped tab of a TabStrip: a close button (a dot instead while the
// tab holds unsaved changes and the pointer is elsewhere) and the title.
// Dragging the title past the drag threshold moves the tab; the strip
// follows the drag signals, in scene coordinates.
T.AbstractButton {
    id: tab

    property string title
    property bool modified: false
    property bool active: false
    // Shown on hover; the title when empty and elided.
    property string toolTip
    // The strip, to keep the window from moving while the pointer is on a tab.
    property TabStrip tabStrip: null
    readonly property bool pointerOverTab: hoverHandler.hovered
    readonly property bool dragging: dragArea.dragging

    readonly property bool dark: Application.styleHints.colorScheme === Qt.ColorScheme.Dark

    signal closeRequested
    signal contextMenuRequested
    signal dragStarted(real sceneX, real sceneY)
    signal dragMoved(real sceneX, real sceneY)
    signal dragFinished(real sceneX, real sceneY)
    signal dragCanceled

    implicitWidth: 150
    implicitHeight: 32
    leftPadding: 4
    rightPadding: 10
    hoverEnabled: true

    Accessible.role: Accessible.PageTab
    Accessible.name: tab.title
    Accessible.selected: tab.active

    SystemPalette {
        id: systemPalette

        colorGroup: SystemPalette.Active
    }

    HoverHandler {
        id: hoverHandler

        onHoveredChanged: {
            if (tab.tabStrip)
                tab.tabStrip.updateWindowMovable();
        }
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: tab.contextMenuRequested()
    }

    HelpTag {
        enabled: !tab.dragging && (tab.toolTip !== "" || titleLabel.truncated)
        text: tab.toolTip !== "" ? tab.toolTip : tab.title
    }

    background: GlassSurface {
        radius: height / 2
        // The active tab is a denser pane washed with the accent.
        density: tab.active ? 1.3 : 1
        tint: systemPalette.accent
        tintStrength: tab.active ? 0.15 : 0
        borderColor: tab.active ? Qt.rgba(systemPalette.accent.r, systemPalette.accent.g, systemPalette.accent.b, 0.5) : (tab.dark ? Qt.rgba(1, 1, 1, 0.13) : Qt.rgba(0, 0, 0, 0.10))
    }

    contentItem: Item {
        implicitHeight: 32

        T.AbstractButton {
            id: closeButton

            readonly property bool showsDot: tab.modified && !tab.hovered

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 22
            height: 22
            enabled: tab.enabled
            hoverEnabled: true

            Accessible.name: qsTr("Close tab")
            onClicked: tab.closeRequested()

            background: Rectangle {
                radius: width / 2
                color: closeButton.hovered && !closeButton.showsDot ? Qt.rgba(systemPalette.windowText.r, systemPalette.windowText.g, systemPalette.windowText.b, closeButton.down ? 0.18 : 0.12) : "transparent"
            }

            contentItem: Item {
                // The unsaved-changes dot.
                Rectangle {
                    anchors.centerIn: parent
                    width: 8
                    height: 8
                    radius: 4
                    visible: closeButton.showsDot
                    color: systemPalette.windowText
                    opacity: 0.7
                }

                // The ×, two strokes.
                Repeater {
                    model: [45, -45]

                    Rectangle {
                        required property int modelData

                        anchors.centerIn: parent
                        width: 10
                        height: 1.5
                        radius: 0.75
                        rotation: modelData
                        visible: !closeButton.showsDot
                        color: systemPalette.windowText
                        opacity: tab.active || closeButton.hovered ? 0.85 : 0.55
                    }
                }
            }
        }

        Text {
            id: titleLabel

            anchors.left: closeButton.right
            anchors.leftMargin: 6
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: tab.title
            color: systemPalette.windowText
            elide: Text.ElideMiddle
            horizontalAlignment: Text.AlignHCenter
        }

        // A click activates; moving past the drag threshold drags the tab.
        MouseArea {
            id: dragArea

            property real pressSceneX: 0
            property real pressSceneY: 0
            property bool dragging: false

            anchors.fill: titleLabel
            acceptedButtons: Qt.LeftButton
            preventStealing: true
            cursorShape: dragging ? Qt.ClosedHandCursor : Qt.ArrowCursor

            function release() {
                if (tab.tabStrip) {
                    tab.tabStrip.tabPointerPressed = false;
                    tab.tabStrip.updateWindowMovable();
                }
            }

            onPressed: mouse => {
                const point = dragArea.mapToItem(null, mouse.x, mouse.y);
                pressSceneX = point.x;
                pressSceneY = point.y;
                dragging = false;
                if (tab.tabStrip) {
                    tab.tabStrip.tabPointerPressed = true;
                    tab.tabStrip.updateWindowMovable();
                }
            }
            onPositionChanged: mouse => {
                const point = dragArea.mapToItem(null, mouse.x, mouse.y);
                if (!dragging) {
                    if (Math.hypot(point.x - pressSceneX, point.y - pressSceneY) < Application.styleHints.startDragDistance)
                        return;
                    dragging = true;
                    tab.dragStarted(pressSceneX, pressSceneY);
                }
                tab.dragMoved(point.x, point.y);
            }
            // Released first: what the signals start may destroy the tab.
            onReleased: mouse => {
                const point = dragArea.mapToItem(null, mouse.x, mouse.y);
                const wasDragging = dragging;
                dragging = false;
                release();
                if (wasDragging)
                    tab.dragFinished(point.x, point.y);
                else
                    tab.clicked();
            }
            onCanceled: {
                const wasDragging = dragging;
                dragging = false;
                release();
                if (wasDragging)
                    tab.dragCanceled();
            }
        }
    }
}
