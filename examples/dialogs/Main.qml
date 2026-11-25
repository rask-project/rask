import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Rask.Dialogs
import Rask.Updater

ApplicationWindow {
    id: root

    width: 520
    height: 360
    visible: true
    title: "Rask Dialogs"

    // English on purpose: Qt moves these into the macOS app menu by matching "About" and "Quit".
    menuBar: MenuBar {
        Menu {
            title: qsTr("Help")

            MenuItem {
                text: "About Rask Dialogs"
                onTriggered: aboutDialog.open()
            }
            MenuItem {
                text: "About Qt"
                onTriggered: aboutQtDialog.open()
            }
        }
    }

    AboutDialog {
        id: aboutDialog

        version: "Version " + Qt.application.version + " (example)"
    }

    AboutQtDialog {
        id: aboutQtDialog
    }

    Alert {
        id: saveAlert

        window: root
        style: Alert.Warning
        text: qsTr("Do you want to save the changes made to “Untitled”?")
        informativeText: qsTr("Your changes will be lost if you don’t save them.")
        buttons: [qsTr("Save"), qsTr("Don’t Save"), qsTr("Cancel")]
        onFinished: button => resultLabel.text = buttons[button]
    }

    Alert {
        id: modalAlert

        text: qsTr("An app-modal alert")
        informativeText: qsTr("Without a window it is not a sheet.")
        onFinished: button => resultLabel.text = qsTr("OK (%1)").arg(button)
    }

    // The menu bar exists once the window is complete; Sparkle adds its item then.
    Component.onCompleted: Updater.start()

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        Button {
            Layout.fillWidth: true
            text: qsTr("About…")
            onClicked: aboutDialog.open()
        }
        Button {
            Layout.fillWidth: true
            text: qsTr("About Qt…")
            onClicked: aboutQtDialog.open()
        }
        Button {
            Layout.fillWidth: true
            text: qsTr("Save Changes? (sheet)")
            onClicked: saveAlert.open()
        }
        Button {
            Layout.fillWidth: true
            text: qsTr("App-modal Alert")
            onClicked: modalAlert.open()
        }
        Button {
            Layout.fillWidth: true
            enabled: Updater.available
            text: qsTr("Check for Updates…")
            onClicked: Updater.checkForUpdates()
        }
        Label {
            id: resultLabel

            Layout.alignment: Qt.AlignHCenter
            text: Updater.available ? "" : qsTr("Updates are off: no SUFeedURL/SUPublicEDKey in Info.plist")
        }
    }
}
