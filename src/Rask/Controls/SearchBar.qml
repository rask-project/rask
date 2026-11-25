import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// A find (and, with `replacing`, replace) bar in the style of Xcode's. It
// only collects the query and reports what the user asks for; the app runs
// the search and feeds back `matchCount`, `currentMatch` and `error`.
// Return finds the next match, Shift+Return the previous one, Escape is done.
Item {
    id: searchBar

    property alias text: findField.text
    property alias replacementText: replaceField.text
    property bool replacing: false
    property bool caseSensitive: false
    property bool regularExpression: false
    property int matchCount: 0
    // The match that is selected, from 0; -1: none.
    property int currentMatch: -1
    // `matchCount` is final (the search is not still running).
    property bool complete: true
    // Why the query cannot be searched for (an invalid expression); empty: it can.
    property string error

    signal next
    signal previous
    signal replace
    signal replaceAll
    signal done

    // Focuses the find field with its text selected.
    function focusFind() {
        findField.forceActiveFocus();
        findField.selectAll();
    }

    readonly property bool dark: Application.styleHints.colorScheme === Qt.ColorScheme.Dark
    readonly property color separatorColor: dark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.1)
    readonly property color secondaryTextColor: dark ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.5)

    implicitHeight: column.implicitHeight + 12

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: searchBar.separatorColor
    }

    ColumnLayout {
        id: column

        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        spacing: 6

        RowLayout {
            spacing: 6

            TextField {
                id: findField

                Layout.fillWidth: true
                placeholderText: qsTr("Find")
                Accessible.name: qsTr("Find")
                Keys.onReturnPressed: event => (event.modifiers & Qt.ShiftModifier) ? searchBar.previous() : searchBar.next()
                Keys.onEnterPressed: searchBar.next()
                Keys.onEscapePressed: searchBar.done()
            }
            Label {
                text: {
                    if (searchBar.error !== "")
                        return searchBar.error;
                    if (searchBar.text === "")
                        return "";
                    const count = searchBar.complete ? searchBar.matchCount : qsTr("%1+").arg(searchBar.matchCount);
                    if (searchBar.currentMatch >= 0)
                        return qsTr("%1 of %2").arg(searchBar.currentMatch + 1).arg(count);
                    return searchBar.matchCount === 1 && searchBar.complete ? qsTr("1 match") : qsTr("%1 matches").arg(count);
                }
                color: searchBar.error !== "" ? "#ff453a" : searchBar.secondaryTextColor
                font.pixelSize: 11
            }
            Button {
                text: "Aa"
                checkable: true
                checked: searchBar.caseSensitive
                flat: true
                Accessible.name: qsTr("Match case")
                ToolTip.text: qsTr("Match case")
                ToolTip.visible: hovered
                ToolTip.delay: 600
                onToggled: searchBar.caseSensitive = checked
            }
            Button {
                text: ".*"
                checkable: true
                checked: searchBar.regularExpression
                flat: true
                Accessible.name: qsTr("Regular expression")
                ToolTip.text: qsTr("Regular expression")
                ToolTip.visible: hovered
                ToolTip.delay: 600
                onToggled: searchBar.regularExpression = checked
            }
            Button {
                text: "‹"
                enabled: searchBar.matchCount > 0
                Accessible.name: qsTr("Previous match")
                onClicked: searchBar.previous()
            }
            Button {
                text: "›"
                enabled: searchBar.matchCount > 0
                Accessible.name: qsTr("Next match")
                onClicked: searchBar.next()
            }
            Button {
                text: qsTr("Done")
                onClicked: searchBar.done()
            }
        }

        RowLayout {
            visible: searchBar.replacing
            spacing: 6

            TextField {
                id: replaceField

                Layout.fillWidth: true
                placeholderText: qsTr("Replace")
                Accessible.name: qsTr("Replace")
                Keys.onReturnPressed: searchBar.replace()
                Keys.onEnterPressed: searchBar.replace()
                Keys.onEscapePressed: searchBar.done()
            }
            Button {
                text: qsTr("Replace")
                enabled: searchBar.currentMatch >= 0
                onClicked: searchBar.replace()
            }
            Button {
                text: qsTr("All")
                enabled: searchBar.matchCount > 0
                Accessible.name: qsTr("Replace all")
                onClicked: searchBar.replaceAll()
            }
        }
    }
}
