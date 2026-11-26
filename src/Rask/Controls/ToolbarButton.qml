pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

// A button of a ToolbarGroup: an icon (`icon.name`, e.g. an SF Symbol such
// as "chevron.backward", or `icon.source`), a light fill under the pointer and
// a hairline before it when another button precedes it in the group.
T.ToolButton {
    id: button

    // Shown in a HelpTag when the pointer rests on the button.
    property string toolTip
    readonly property bool dark: Application.styleHints.colorScheme === Qt.ColorScheme.Dark

    implicitWidth: 40
    implicitHeight: 36
    padding: 0
    focusPolicy: Qt.NoFocus
    hoverEnabled: true
    icon.width: 17
    icon.height: 17
    icon.color: dark ? "white" : "black"

    background: Item {
        Rectangle {
            anchors.fill: parent
            anchors.margins: 3
            radius: height / 2
            color: button.dark ? "white" : "black"
            opacity: !button.enabled || !button.hovered ? 0 : (button.down ? 0.16 : 0.08)
        }

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 1
            height: parent.height * 0.5
            visible: !button.Positioner.isFirstItem
            color: button.dark ? "white" : "black"
            opacity: button.dark ? 0.18 : 0.12
        }
    }

    HelpTag {
        text: button.toolTip
    }

    // IconImage draws the symbol once, in the button's state then (faded
    // when disabled): a new one for each state.
    contentItem: Item {
        implicitWidth: button.icon.width
        implicitHeight: button.icon.height

        Repeater {
            model: [button.enabled]

            IconImage {
                anchors.centerIn: parent
                name: button.icon.name
                source: button.icon.source
                sourceSize.width: button.icon.width
                sourceSize.height: button.icon.height
                fillMode: Image.Pad
                color: button.icon.color
                opacity: button.enabled ? 0.85 : 0.3
            }
        }
    }
}
