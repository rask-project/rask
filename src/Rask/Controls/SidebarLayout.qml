pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// The layout of macOS System Settings for a window whose content extends under
// the title bar (a NativeWindow): a full-height sidebar under the window
// buttons, transparent so the window's blur shows through, and an opaque
// content pane with the current section's title next to the buttons and its
// page below. Pages are the children, one per section, in order.
//
//   SidebarLayout {
//       anchors.fill: parent
//       titleBarHeight: window.SafeArea.margins.top
//       sections: [{ title: qsTr("General"), iconSource: Qt.resolvedUrl("icons/general.svg") }]
//       ColumnLayout { FormGroup { FormRow { … } } }
//   }
//
// A page taller than the content pane scrolls.
Item {
    id: layout

    // [{ title, iconName or iconSource, badge (optional) }]. The icons are the
    // app's: a theme icon name, or an image URL (Qt.resolvedUrl() it where the
    // array is written, since it is resolved here otherwise).
    property var sections: []
    property int currentIndex: 0
    property real sidebarWidth: 210
    // Height of the title bar the content extends under: the window's
    // SafeArea.margins.top.
    property real titleBarHeight: 28
    property color contentColor: systemPalette.window
    default property alias pages: stack.data

    readonly property string currentTitle: layout.sections.length > layout.currentIndex ? layout.sections[layout.currentIndex].title : ""
    readonly property bool dark: Application.styleHints.colorScheme === Qt.ColorScheme.Dark
    readonly property color separatorColor: dark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.1)

    SystemPalette {
        id: systemPalette

        colorGroup: SystemPalette.Active
    }

    // Opaque content pane right of the sidebar, separated by a hairline.
    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: parent.width - layout.sidebarWidth

        color: layout.contentColor

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1

            color: layout.separatorColor
        }
    }

    RowLayout {
        anchors.fill: parent

        spacing: 0

        // Sidebar: edge to edge, transparent so the window blur shows through.
        ColumnLayout {
            // Its rows fill width, which would make the column stretch too;
            // pin it so it ends exactly at the content pane's hairline.
            Layout.fillWidth: false
            Layout.minimumWidth: layout.sidebarWidth - 20
            Layout.maximumWidth: layout.sidebarWidth - 20
            Layout.fillHeight: true
            Layout.topMargin: layout.titleBarHeight + 6
            Layout.leftMargin: 10
            Layout.rightMargin: 10

            spacing: 2

            Repeater {
                model: layout.sections

                delegate: SidebarItem {
                    required property int index
                    required property var modelData

                    title: modelData.title
                    iconName: modelData.iconName ?? ""
                    iconSource: modelData.iconSource ?? ""
                    badge: modelData.badge ?? ""
                    selected: layout.currentIndex === index
                    onClicked: layout.currentIndex = index
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 0

            // Section title, vertically centered with the window buttons.
            Label {
                Layout.fillWidth: true
                Layout.preferredHeight: layout.titleBarHeight
                Layout.leftMargin: 24
                Layout.rightMargin: 24
                Layout.bottomMargin: 16

                text: layout.currentTitle
                font.pointSize: 15
                font.weight: Font.Bold
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            Flickable {
                id: scroller

                readonly property Item page: stack.children[stack.currentIndex] ?? null

                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true
                contentWidth: width
                // The page's bottom margin scrolls with it.
                contentHeight: stack.height + 24
                boundsBehavior: Flickable.StopAtBounds

                ScrollBar.vertical: OverlayScrollBar {}

                StackLayout {
                    id: stack

                    x: 24
                    width: scroller.width - 48
                    height: Math.max(scroller.height - 24, scroller.page?.implicitHeight ?? 0)

                    currentIndex: layout.currentIndex
                    onCurrentIndexChanged: scroller.contentY = 0
                }
            }
        }
    }
}
