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
    flags: nativeWindow.translucent ? (Qt.Window | Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint) : Qt.Window
    color: nativeWindow.translucent ? "transparent" : palette.window

    NativeWindow {
        id: nativeWindow

        window: root
        color: Appearance.dark ? "#1c1c1e" : "#f5f5f7"
        alpha: alphaSlider.value
        blur: blurSwitch.checked
        unifiedToolbar: root.visibility !== Window.FullScreen
    }

    // The title bar: starts after the window buttons; a double click does what System Settings says.
    Item {
        id: titleBar

        anchors.left: parent.left
        anchors.right: parent.right
        height: 52

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
            text: nativeWindow.translucent ? nativeWindow.leadingInset.toFixed(1) : "not supported"
        }
    }
}
