import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T

// A text field in macOS's filled style (the Human Interface Guidelines'
// second one): a rounded fill, no border or focus ring, and a button that
// clears it while it holds text and has the focus or the pointer.
T.TextField {
    id: field

    // The clear button (on by default).
    property bool clearable: true

    readonly property bool dark: Application.styleHints.colorScheme === Qt.ColorScheme.Dark

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, placeholder.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)

    leftPadding: 10
    rightPadding: clearButton.visible ? clearButton.width + 12 : 10
    topPadding: 5
    bottomPadding: 5
    verticalAlignment: TextInput.AlignVCenter
    hoverEnabled: true
    font.pixelSize: 13
    color: dark ? "white" : "black"
    placeholderTextColor: dark ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(0, 0, 0, 0.3)
    selectionColor: palette.highlight
    selectedTextColor: palette.highlightedText

    PlaceholderText {
        id: placeholder

        x: field.leftPadding
        y: field.topPadding
        width: field.width - (field.leftPadding + field.rightPadding)
        height: field.height - (field.topPadding + field.bottomPadding)
        text: field.placeholderText
        font: field.font
        color: field.placeholderTextColor
        verticalAlignment: field.verticalAlignment
        elide: Text.ElideRight
        renderType: field.renderType
        visible: !field.length && !field.preeditText
    }

    background: Rectangle {
        implicitWidth: 160
        implicitHeight: 28
        radius: 8
        color: field.dark ? Qt.rgba(1, 1, 1, field.activeFocus ? 0.12 : 0.07) : Qt.rgba(0, 0, 0, field.activeFocus ? 0.08 : 0.05)
    }

    T.AbstractButton {
        id: clearButton

        anchors.right: parent.right
        anchors.rightMargin: 7
        anchors.verticalCenter: parent.verticalCenter
        width: 16
        height: 16
        visible: field.clearable && field.length > 0 && (field.activeFocus || field.hovered)
        focusPolicy: Qt.NoFocus
        hoverEnabled: true

        contentItem: IconImage {
            name: "xmark.circle.fill"
            sourceSize.width: 16
            sourceSize.height: 16
            color: field.dark ? Qt.rgba(1, 1, 1, clearButton.hovered ? 0.7 : 0.45) : Qt.rgba(0, 0, 0, clearButton.hovered ? 0.55 : 0.35)
        }

        onClicked: {
            field.clear();
            field.forceActiveFocus();
        }
    }
}
