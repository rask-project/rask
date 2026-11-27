pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Layouts
import QtQuick.Templates as T

// A find (and, with `replacing`, replace) bar in the style of Xcode's. It
// only collects the query and reports what the user asks for; the app runs
// the search and feeds back `matchCount`, `currentMatch` and `error`.
// Return finds the next match, Shift+Return the previous one, Escape is done.
// The buttons are flat, with system icons (SF Symbols) as in Xcode's bar.
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
    readonly property color textColor: dark ? "white" : "black"

    SystemPalette {
        id: systemPalette

        colorGroup: SystemPalette.Active
    }

    // Flat: a light fill under the pointer, the accent when checked. Not
    // `enabled` but `available`: IconImage draws the symbol once, in the
    // state the button had then (clicks are ignored while unavailable).
    component BarButton: T.ToolButton {
        id: barButton

        property string toolTip
        property bool available: true

        implicitWidth: Math.max(26, implicitContentWidth + leftPadding + rightPadding)
        implicitHeight: 24
        leftPadding: text !== "" ? 8 : 0
        rightPadding: leftPadding
        focusPolicy: Qt.NoFocus
        hoverEnabled: true
        icon.width: 14
        icon.height: 14

        background: Rectangle {
            radius: 6
            color: {
                if (barButton.checked)
                    return Qt.alpha(systemPalette.accent, barButton.down ? 0.32 : 0.22);
                if (barButton.hovered && barButton.available)
                    return Qt.alpha(searchBar.textColor, barButton.down ? 0.16 : 0.08);
                return "transparent";
            }
        }

        contentItem: Item {
            implicitWidth: barButton.text !== "" ? label.implicitWidth : barButton.icon.width
            implicitHeight: barButton.icon.height

            IconImage {
                anchors.centerIn: parent
                visible: barButton.text === ""
                name: barButton.icon.name
                sourceSize.width: barButton.icon.width
                sourceSize.height: barButton.icon.height
                fillMode: Image.Pad
                color: barButton.checked ? systemPalette.accent : searchBar.textColor
                opacity: !barButton.available ? 0.35 : (barButton.hovered || barButton.checked ? 1 : 0.8)
            }

            Text {
                id: label

                anchors.centerIn: parent
                visible: barButton.text !== ""
                text: barButton.text
                font.pixelSize: 12
                color: searchBar.textColor
                opacity: !barButton.available ? 0.35 : (barButton.hovered ? 1 : 0.8)
            }
        }

        HelpTag {
            text: barButton.toolTip
        }
    }

    implicitHeight: column.implicitHeight + 24

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: searchBar.separatorColor
    }

    // The fields in a column of their own, so they line up; the buttons beside them.
    GridLayout {
        id: column

        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        columns: 2
        rowSpacing: 6
        columnSpacing: 6

        FilledTextField {
            id: findField

            Layout.fillWidth: true
            placeholderText: qsTr("Find")
            Accessible.name: qsTr("Find")
            Keys.onReturnPressed: event => (event.modifiers & Qt.ShiftModifier) ? searchBar.previous() : searchBar.next()
            Keys.onEnterPressed: searchBar.next()
            Keys.onEscapePressed: searchBar.done()
        }
        RowLayout {
            id: findButtons

            spacing: 6

            BarButton {
                icon.name: "textformat"
                // A wide symbol: room to match the others' height.
                icon.width: 20
                checkable: true
                checked: searchBar.caseSensitive
                Accessible.name: qsTr("Match case")
                toolTip: qsTr("Match Case")
                onToggled: searchBar.caseSensitive = checked
            }
            BarButton {
                icon.name: "asterisk"
                checkable: true
                checked: searchBar.regularExpression
                Accessible.name: qsTr("Regular expression")
                toolTip: qsTr("Regular Expression")
                onToggled: searchBar.regularExpression = checked
            }
            BarButton {
                icon.name: "chevron.backward"
                available: searchBar.matchCount > 0
                Accessible.name: qsTr("Previous match")
                toolTip: qsTr("Previous Match")
                onClicked: {
                    if (available)
                        searchBar.previous();
                }
            }
            BarButton {
                icon.name: "chevron.forward"
                available: searchBar.matchCount > 0
                Accessible.name: qsTr("Next match")
                toolTip: qsTr("Next Match")
                onClicked: {
                    if (available)
                        searchBar.next();
                }
            }
            BarButton {
                icon.name: "xmark"
                icon.width: 12
                icon.height: 12
                Accessible.name: qsTr("Done")
                toolTip: qsTr("Done")
                onClicked: searchBar.done()
            }
        }

        FilledTextField {
            id: replaceField

            visible: searchBar.replacing
            Layout.fillWidth: true
            placeholderText: qsTr("Replace")
            Accessible.name: qsTr("Replace")
            Keys.onReturnPressed: searchBar.replace()
            Keys.onEnterPressed: searchBar.replace()
            Keys.onEscapePressed: searchBar.done()
        }
        // As wide as the buttons above, leaving the rest to the fields.
        RowLayout {
            visible: searchBar.replacing
            Layout.fillWidth: false
            Layout.preferredWidth: findButtons.implicitWidth
            spacing: 6

            BarButton {
                Layout.fillWidth: true
                text: qsTr("Replace")
                available: searchBar.currentMatch >= 0
                onClicked: {
                    if (available)
                        searchBar.replace();
                }
            }
            BarButton {
                Layout.fillWidth: true
                text: qsTr("All")
                available: searchBar.matchCount > 0
                Accessible.name: qsTr("Replace all")
                toolTip: qsTr("Replace All")
                onClicked: {
                    if (available)
                        searchBar.replaceAll();
                }
            }
        }
    }

    // The count, a badge over the find field's top right corner (out of the
    // layout: nothing moves as it changes).
    Rectangle {
        visible: countLabel.text !== ""
        x: column.x + findField.x + findField.width - width - 8
        y: column.y + findField.y - height / 2
        width: countLabel.implicitWidth + 12
        height: countLabel.implicitHeight + 2
        radius: height / 2
        color: searchBar.error !== "" ? "#ff453a" : systemPalette.accent

        Label {
            id: countLabel

            anchors.centerIn: parent
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
            color: "white"
            font.pixelSize: 10
        }
    }
}
