import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Rask.Platform
import Rask.Window

ApplicationWindow {
    id: root

    width: 640
    height: 420
    visible: true
    title: "Rask Window"
    flags: Qt.Window | Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint
    color: "transparent"
    // ApplicationWindow pads its content by the safe area (Qt 6.9+); the title
    // bar draws in the toolbar area itself, like Konsoll's tab strip.
    topPadding: 0

    NativeWindow {
        id: nativeWindow

        window: root
        color: Appearance.dark ? "#1c1c1e" : "#f5f5f7"
        alpha: alphaSlider.value
        blur: blurSwitch.checked
        unifiedToolbar: root.visibility !== Window.FullScreen
    }

    // The title bar covers the toolbar area with the window buttons in it, its
    // content starting after them; a double click does what System Settings says.
    Item {
        id: titleBar

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.max(root.SafeArea.margins.top, 40)

        // Native Liquid Glass behind the bar (macOS 26+), else the same look drawn in QML.
        GlassEffect {
            id: barGlass

            anchors.fill: parent
            visible: supported && glassSwitch.checked
            cornerRadius: 0
        }
        GlassSurface {
            anchors.fill: parent
            visible: !barGlass.supported && glassSwitch.checked
            radius: 0
            density: 0.6
            borderWidth: 0
        }

        TapHandler {
            onDoubleTapped: nativeWindow.titleBarDoubleClicked()
        }

        Label {
            anchors.left: parent.left
            anchors.leftMargin: nativeWindow.leadingInset + 12
            anchors.verticalCenter: parent.verticalCenter
            text: root.title
            font.bold: true
        }

        // A tinted glass pill, like the active tab.
        Item {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 120
            height: 30

            GlassEffect {
                id: pillGlass

                anchors.fill: parent
                visible: supported
                cornerRadius: height / 2
                tint: Qt.rgba(0.2, 0.5, 1.0, 0.35)
            }
            GlassSurface {
                anchors.fill: parent
                visible: !pillGlass.supported
                tint: "#3380ff"
                tintStrength: 0.35
            }
            Label {
                anchors.centerIn: parent
                text: pillGlass.supported ? "Liquid Glass" : "QML glass"
            }
        }
    }

    GridLayout {
        anchors.top: titleBar.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 24
        columns: 2
        columnSpacing: 16
        rowSpacing: 12

        Label {
            text: "Appearance"
        }
        ComboBox {
            // Like an NSPopUpButton: no focus (and focus ring) from a click.
            focusPolicy: Qt.TabFocus
            model: ["System", "Light", "Dark"]
            currentIndex: Appearance.colorScheme
            onActivated: index => Appearance.colorScheme = index
        }

        Label {
            text: "Blur"
        }
        Switch {
            id: blurSwitch

            checked: true
        }

        Label {
            text: "Glass bar"
        }
        Switch {
            id: glassSwitch

            checked: true
        }

        Label {
            text: "Opacity"
        }
        Slider {
            id: alphaSlider

            from: 0.2
            to: 1.0
            value: 0.75
        }

        Label {
            text: "Leading inset"
        }
        Label {
            text: nativeWindow.leadingInset.toFixed(1)
        }
    }
}
