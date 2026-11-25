pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import Rask.Application
import Rask.Controls
import Rask.Dialogs
import Rask.Platform
import Rask.Window

// Documents in tabs: files from the Finder and the Dock (FileOpenHandler),
// an Open Recent menu (RecentDocuments), and a question before quitting
// with unsaved tabs (QuitGuard). Typing in a tab marks it modified.
ApplicationWindow {
    id: root

    property list<Document> documents: []
    property int currentIndex: -1
    readonly property Document current: root.documents[root.currentIndex] ?? null

    function open(file: url) {
        RecentDocuments.add(file);
        const document = documentComponent.createObject(root, {
            file: file
        });
        root.documents.push(document);
        root.currentIndex = root.documents.length - 1;
    }

    function close(index: int) {
        const closed = root.documents[index];
        root.documents.splice(index, 1);
        root.currentIndex = Math.min(root.currentIndex, root.documents.length - 1);
        closed.destroy();
    }

    width: 760
    height: 420
    visible: true
    title: root.current ? root.current.title : "Rask Documents"
    flags: Qt.Window | Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint
    color: "transparent"
    topPadding: 0

    component Document: QtObject {
        property url file
        property bool modified: false
        readonly property string title: file.toString() === "" ? "Untitled" : file.toString().split("/").pop()
        readonly property string toolTip: file.toString()
    }

    Component {
        id: documentComponent

        Document {}
    }

    NativeWindow {
        id: native

        window: root
        color: Appearance.dark ? "#1e1e1e" : "#fbfbfb"
        representedFile: root.current ? root.current.file : ""
        documentEdited: root.current ? root.current.modified : false
    }

    Connections {
        target: FileOpenHandler

        function onFilesOpened(files: list<url>) {
            files.forEach(file => root.open(file));
        }
    }

    Connections {
        target: QuitGuard

        function onQuitRequested() {
            if (!root.documents.some(document => document.modified))
                QuitGuard.quit();
            else
                quitAlert.open();
        }
    }

    Alert {
        id: quitAlert

        window: root
        style: Alert.Warning
        text: qsTr("Quit with unsaved documents?")
        informativeText: qsTr("Their changes will be lost.")
        buttons: [qsTr("Quit"), qsTr("Cancel")]
        onFinished: button => {
            if (button === 0)
                QuitGuard.quit();
        }
    }

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")

            MenuItem {
                text: qsTr("New Tab")
                onTriggered: root.open("")
            }
            Menu {
                id: recentMenu

                title: qsTr("Open Recent")

                Instantiator {
                    model: RecentDocuments.files

                    delegate: MenuItem {
                        required property url modelData

                        text: modelData.toString().split("/").pop()
                        onTriggered: root.open(modelData)
                    }

                    onObjectAdded: (index, object) => recentMenu.insertItem(index, object)
                    onObjectRemoved: (index, object) => recentMenu.removeItem(object)
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Clear Menu")
                    enabled: RecentDocuments.files.length > 0
                    onTriggered: RecentDocuments.clear()
                }
            }
        }
    }

    TabStrip {
        id: tabStrip

        anchors.left: parent.left
        anchors.right: parent.right
        height: requiredHeight
        baseSafeTop: root.SafeArea.margins.top
        leadingInset: native.leadingInset
        nativeWindow: native
        tabs: root.documents
        currentIndex: root.currentIndex
        onActivateRequested: index => root.currentIndex = index
        onCloseRequested: index => root.close(index)
        onAddRequested: root.open("")
        onReorderRequested: (fromIndex, toIndex) => {
            const moved = root.documents[fromIndex];
            root.documents.splice(fromIndex, 1);
            root.documents.splice(toIndex, 0, moved);
            root.currentIndex = toIndex;
        }
    }

    TextArea {
        anchors.top: tabStrip.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 16
        enabled: root.current !== null
        placeholderText: qsTr("Open text files from the Finder (Open With) or drop them on the Dock icon; type here to mark the tab modified.")
        wrapMode: TextEdit.Wrap
        onTextEdited: if (root.current)
            root.current.modified = true
    }

    Component.onCompleted: root.open("")
}
