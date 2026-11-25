pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Rask.Controls
import Rask.Platform
import Rask.Updater
import Rask.Window

// A Settings window like macOS System Settings: the sidebar shows the native
// blur through the window, the selected section gets the accent pill, and the
// content pane has an opaque background.
Window {
    id: root

    readonly property string badges: "qrc:/qt/qml/Rask/Controls/icons/"
    readonly property color secondaryTextColor: Appearance.dark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.5)

    width: 720
    height: 480
    minimumWidth: 720
    maximumWidth: 720
    minimumHeight: 480
    maximumHeight: 480
    visible: true
    // Feeds the Window menu and the window switcher; the section title is drawn by QML.
    title: settings.currentTitle

    // Close and minimize only (no zoom), content under a transparent title bar.
    flags: Qt.Window | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.WindowMinimizeButtonHint | Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint
    color: "transparent"

    NativeWindow {
        window: root
        color: Appearance.dark ? "#1e1e1e" : "#e8e8e8"
        alpha: opacitySlider.value
        blur: blurSwitch.checked
    }

    SidebarLayout {
        id: settings

        anchors.fill: parent
        titleBarHeight: Math.max(root.SafeArea.margins.top, 28)
        sections: [
            {
                title: qsTr("Appearance"),
                iconSource: root.badges + "appearance.svg"
            },
            {
                title: qsTr("Window"),
                iconSource: root.badges + "window.svg"
            },
            {
                title: qsTr("Keyboard"),
                iconSource: root.badges + "keyboard.svg"
            },
            {
                title: qsTr("Security"),
                iconSource: root.badges + "security.svg"
            },
            {
                title: qsTr("Updates"),
                iconSource: root.badges + "updates.svg",
                badge: Updater.available ? "" : "off"
            }
        ]

        // Appearance
        ColumnLayout {
            spacing: 6

            FormGroup {
                FormRow {
                    label: qsTr("Appearance")
                    detail: qsTr("Light, dark, or as the system")
                    showSeparator: false

                    ComboBox {
                        Layout.preferredWidth: 150
                        model: [qsTr("System"), qsTr("Light"), qsTr("Dark")]
                        currentIndex: Appearance.colorScheme
                        onActivated: index => Appearance.colorScheme = index
                    }
                }
            }

            FormGroup {
                FormRow {
                    label: qsTr("Font")
                    detail: "Menlo 13 pt"
                    monospaceDetail: true
                    showSeparator: false

                    Button {
                        text: qsTr("Change…")
                    }
                }

                FormRow {
                    label: qsTr("Show line numbers")

                    Switch {
                        checked: true
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }

        // Window
        ColumnLayout {
            spacing: 6

            FormGroup {
                FormRow {
                    label: qsTr("Background blur")
                    showSeparator: false

                    Switch {
                        id: blurSwitch

                        checked: true
                    }
                }

                FormRow {
                    label: qsTr("Background opacity")

                    Slider {
                        id: opacitySlider

                        Layout.preferredWidth: 180
                        from: 0.3
                        to: 1.0
                        value: 0.9
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                text: qsTr("The sidebar shows the desktop through the window's blur; the content pane stays opaque.")
                font.pointSize: 11
                color: root.secondaryTextColor
                wrapMode: Text.Wrap
            }

            Item {
                Layout.fillHeight: true
            }
        }

        // Keyboard
        ColumnLayout {
            spacing: 6

            FormGroup {
                FormRow {
                    label: qsTr("Option key as Meta")
                    showSeparator: false

                    Switch {}
                }

                FormRow {
                    label: qsTr("Tab width")

                    SpinBox {
                        from: 1
                        to: 8
                        value: 4
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }

        // Security: selectable rows with leading icons
        ColumnLayout {
            spacing: 6

            FormGroup {
                Repeater {
                    model: [qsTr("Ask before reading the clipboard"), qsTr("Allow programs to read the clipboard"), qsTr("Never allow")]

                    delegate: FormRow {
                        required property int index
                        required property string modelData

                        label: modelData
                        showSeparator: index > 0
                        selectable: true
                        highlighted: clipboardPolicy.current === index
                        onClicked: clipboardPolicy.current = index

                        leading: Image {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            source: root.badges + "security.svg"
                            sourceSize: Qt.size(40, 40)
                        }
                    }
                }
            }

            QtObject {
                id: clipboardPolicy

                property int current: 0
            }

            Item {
                Layout.fillHeight: true
            }
        }

        // Updates
        ColumnLayout {
            spacing: 6

            FormGroup {
                FormRow {
                    label: qsTr("Check for updates automatically")
                    showSeparator: false
                    enabled: Updater.available

                    Switch {
                        checked: Updater.automaticChecks
                        onToggled: Updater.automaticChecks = checked
                    }
                }

                FormRow {
                    label: qsTr("Include beta versions")

                    Switch {
                        checked: Updater.betaUpdates
                        onToggled: Updater.betaUpdates = checked
                    }
                }

                FormRow {
                    label: qsTr("Last checked")
                    detail: Updater.lastCheck.getTime() ? Updater.lastCheck.toLocaleString() : qsTr("Never")
                    enabled: Updater.available

                    Button {
                        text: qsTr("Check Now")
                        onClicked: Updater.checkForUpdates()
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                visible: !Updater.available
                text: qsTr("Updates are off in this example: its Info.plist has no SUFeedURL or SUPublicEDKey.")
                font.pointSize: 11
                color: root.secondaryTextColor
                wrapMode: Text.Wrap
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
