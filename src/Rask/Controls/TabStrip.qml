pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T

import Rask.Window

// A tab strip in the title bar, after the window buttons: pill-shaped tabs
// that wrap into more rows when they no longer fit, a + button, drag to
// reorder, and drag out of the strip to move a tab to another window (or
// tear it off into a new one). The app owns the tabs; the strip only reports
// what the user asks for.
//
// `tabs` is a list of objects with a `title` and, optionally, `modified`
// (unsaved changes) and `toolTip` properties.
Rectangle {
    id: strip

    property var tabs: []
    property int currentIndex: -1
    // The title bar's height (the window's top safe area); more rows add to it.
    property real baseSafeTop: 40
    // The window buttons' edge (NativeWindow.leadingInset) and what to keep
    // free on the right.
    property real leadingInset: 0
    property real trailingInset: 0
    property real minimumTabWidth: 88
    // Kept from moving while the pointer is on a tab; its title-bar double
    // click runs on empty strip space.
    property NativeWindow nativeWindow: null
    property bool tabPointerPressed: false

    property int dragSourceIndex: -1
    property int dragTargetIndex: -1
    property var dragTab: null
    property bool dragTabActive: false
    property real dragPointerX: 0
    property real dragPointerY: 0
    property real dragGrabOffsetX: 0
    property real dragGrabOffsetY: 0
    // Pointer in global coordinates, and whether it has left the strip to
    // drop the tab on another window (or tear it off into a new one).
    property real dragGlobalX: 0
    property real dragGlobalY: 0
    property bool dragDetached: false

    readonly property real rowHeight: 34
    readonly property real tabSpacing: 6
    readonly property real firstRowWidth: Math.max(0, width - leadingInset - trailingInset - 54)
    readonly property real followingRowWidth: Math.max(0, width - trailingInset - 16)
    readonly property int firstRowCapacity: Math.max(1, Math.floor((firstRowWidth + tabSpacing) / (minimumTabWidth + tabSpacing)))
    readonly property int followingRowCapacity: Math.max(1, Math.floor((followingRowWidth + tabSpacing) / (minimumTabWidth + tabSpacing)))
    readonly property int rowCount: tabs.length <= firstRowCapacity ? 1 : 1 + Math.ceil((tabs.length - firstRowCapacity) / followingRowCapacity)
    readonly property real requiredHeight: Math.max(40, baseSafeTop) + (rowCount - 1) * rowHeight
    readonly property int visualCurrentIndex: dragSourceIndex < 0 ? currentIndex : visualIndex(currentIndex)

    signal activateRequested(int index)
    signal closeRequested(int index)
    signal reorderRequested(int fromIndex, int toIndex)
    signal addRequested
    signal contextMenuRequested(int index)
    // A tab dragged out of the strip and released at a global point.
    signal windowDropRequested(int index, real globalX, real globalY)

    onNativeWindowChanged: updateWindowMovable()
    Component.onCompleted: updateWindowMovable()

    // Native Liquid Glass where the system has it (a tinted fill would wash
    // it out); else the same look in QML over a light veil of the window color.
    color: stripGlass.supported ? "transparent" : Qt.rgba(systemPalette.window.r, systemPalette.window.g, systemPalette.window.b, 0.30)

    SystemPalette {
        id: systemPalette

        colorGroup: SystemPalette.Active
    }

    GlassEffect {
        id: stripGlass

        anchors.fill: parent
        visible: supported
        cornerRadius: 0
    }

    GlassSurface {
        anchors.fill: parent
        visible: !stripGlass.supported
        radius: 0
        density: 0.6
        borderWidth: 0
    }

    // Hairline under the strip.
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        visible: !stripGlass.supported
        color: Application.styleHints.colorScheme === Qt.ColorScheme.Dark ? Qt.rgba(0, 0, 0, 0.35) : Qt.rgba(0, 0, 0, 0.08)
    }

    // The strip covers AppKit's title bar: empty space does its double click.
    TapHandler {
        acceptedButtons: Qt.LeftButton
        onDoubleTapped: {
            if (strip.nativeWindow && strip.dragSourceIndex < 0)
                strip.nativeWindow.titleBarDoubleClicked();
        }
    }

    function tabRow(index) {
        if (index < firstRowCapacity)
            return 0;
        return 1 + Math.floor((index - firstRowCapacity) / followingRowCapacity);
    }

    function firstIndexInRow(row) {
        return row === 0 ? 0 : firstRowCapacity + (row - 1) * followingRowCapacity;
    }

    function itemCountInRow(row) {
        const capacity = row === 0 ? firstRowCapacity : followingRowCapacity;
        return Math.min(capacity, tabs.length - firstIndexInRow(row));
    }

    // Tabs share their row: the current one asks for more room.
    function tabWidth(index) {
        const row = tabRow(index);
        const firstIndex = firstIndexInRow(row);
        const count = itemCountInRow(row);
        const rowWidth = (row === 0 ? firstRowWidth : followingRowWidth) - tabSpacing * (count - 1);
        const minimumWidth = Math.min(minimumTabWidth, rowWidth / count);
        let preferredWidthSum = 0;
        let preferredExcessSum = 0;
        for (let rowIndex = firstIndex; rowIndex < firstIndex + count; ++rowIndex) {
            const preferred = rowIndex === visualCurrentIndex ? 250 : 150;
            preferredWidthSum += preferred;
            preferredExcessSum += preferred - minimumWidth;
        }
        const preferredWidth = index === visualCurrentIndex ? 250 : 150;
        if (preferredWidthSum <= rowWidth)
            return preferredWidth;
        const scale = Math.min(1, (rowWidth - minimumWidth * count) / preferredExcessSum);
        return minimumWidth + (preferredWidth - minimumWidth) * scale;
    }

    function tabX(index) {
        const row = tabRow(index);
        let x = row === 0 ? leadingInset + 8 : 8;
        for (let rowIndex = firstIndexInRow(row); rowIndex < index; ++rowIndex)
            x += tabWidth(rowIndex) + tabSpacing;
        return x;
    }

    function tabY(index) {
        return (Math.max(40, baseSafeTop) - rowHeight) / 2 + tabRow(index) * rowHeight;
    }

    // Where a tab shows while another one is dragged.
    function visualIndex(modelIndex) {
        if (dragSourceIndex < 0)
            return modelIndex;
        const order = [];
        for (let index = 0; index < tabs.length; ++index) {
            if (index !== dragSourceIndex)
                order.push(index);
        }
        order.splice(dragTargetIndex, 0, dragSourceIndex);
        return order.indexOf(modelIndex);
    }

    function nearestTabIndex(x, y) {
        let nearest = -1;
        let nearestDistance = Number.POSITIVE_INFINITY;
        for (let index = 0; index < tabs.length; ++index) {
            const dx = x - tabX(index) - tabWidth(index) / 2;
            const dy = y - tabY(index) - rowHeight / 2;
            const distance = dx * dx + dy * dy;
            if (distance < nearestDistance) {
                nearestDistance = distance;
                nearest = index;
            }
        }
        return nearest;
    }

    // Where a tab dropped at a global point lands: before the first tab whose
    // centre lies past the pointer in its row.
    function insertionIndexAtGlobal(globalX, globalY) {
        const point = strip.mapFromGlobal(globalX, globalY);
        const firstRowY = (Math.max(40, baseSafeTop) - rowHeight) / 2;
        const row = Math.max(0, Math.min(rowCount - 1, Math.floor((point.y - firstRowY) / rowHeight)));
        let insertion = 0;
        for (let index = 0; index < tabs.length; ++index) {
            const indexRow = tabRow(index);
            if (indexRow < row || (indexRow === row && tabX(index) + tabWidth(index) / 2 < point.x))
                insertion = index + 1;
        }
        return insertion;
    }

    // A thin bar where insertionIndexAtGlobal places a dropped tab.
    function insertionMarkerRect(index) {
        if (tabs.length === 0)
            return Qt.rect(leadingInset + 6, tabY(0), 3, 32);
        const after = index >= tabs.length;
        const reference = after ? tabs.length - 1 : index;
        const x = after ? tabX(reference) + tabWidth(reference) + tabSpacing / 2 : tabX(reference) - tabSpacing / 2;
        return Qt.rect(x - 1.5, tabY(reference), 3, 32);
    }

    // Well outside the strip: the drop goes to another window.
    function isDetachPoint(point) {
        return point.y > strip.height + 40 || point.y < -8 || point.x < -8 || point.x > strip.width + 8;
    }

    function updateWindowMovable() {
        let overTab = false;
        for (let index = 0; index < tabRepeater.count; ++index) {
            const tab = tabRepeater.itemAt(index) as TabStripButton;
            if (tab && tab.pointerOverTab) {
                overTab = true;
                break;
            }
        }
        if (nativeWindow)
            nativeWindow.movable = dragSourceIndex < 0 && !tabPointerPressed && !overTab;
    }

    function beginTabDrag(index, sceneX, sceneY) {
        const point = strip.mapFromItem(null, sceneX, sceneY);
        dragTargetIndex = index;
        dragSourceIndex = index;
        dragTab = tabs[index];
        dragTabActive = index === currentIndex;
        dragPointerX = point.x;
        dragPointerY = point.y;
        dragGrabOffsetX = point.x - tabX(index);
        dragGrabOffsetY = point.y - tabY(index);
        updateWindowMovable();
    }

    function moveTabDrag(sceneX, sceneY) {
        const point = strip.mapFromItem(null, sceneX, sceneY);
        dragPointerX = point.x;
        dragPointerY = point.y;
        const global = strip.mapToGlobal(point.x, point.y);
        dragGlobalX = global.x;
        dragGlobalY = global.y;
        dragDetached = isDetachPoint(point);
        if (dragDetached) {
            dragTargetIndex = dragSourceIndex;
            return;
        }
        const targetIndex = nearestTabIndex(point.x, point.y);
        if (targetIndex >= 0 && targetIndex !== dragTargetIndex)
            dragTargetIndex = targetIndex;
    }

    function endTabDrag() {
        dragSourceIndex = -1;
        dragTargetIndex = -1;
        dragTab = null;
        dragDetached = false;
        updateWindowMovable();
    }

    function finishTabDrag(sceneX, sceneY) {
        if (dragSourceIndex < 0)
            return;
        const point = strip.mapFromItem(null, sceneX, sceneY);
        const fromIndex = dragSourceIndex;
        const toIndex = nearestTabIndex(point.x, point.y);
        const global = strip.mapToGlobal(point.x, point.y);
        endTabDrag();
        if (isDetachPoint(point))
            windowDropRequested(fromIndex, global.x, global.y);
        else if (toIndex >= 0 && toIndex !== fromIndex)
            reorderRequested(fromIndex, toIndex);
    }

    Repeater {
        id: tabRepeater

        model: strip.tabs

        delegate: TabStripButton {
            required property int index
            required property var modelData

            readonly property int layoutIndex: strip.visualIndex(index)

            x: strip.tabX(layoutIndex)
            y: strip.tabY(layoutIndex)
            width: strip.tabWidth(layoutIndex)
            opacity: index === strip.dragSourceIndex ? 0 : 1

            Behavior on x {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on y {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                }
            }

            title: modelData ? (modelData.title ?? "") : ""
            modified: modelData ? (modelData.modified ?? false) : false
            toolTip: modelData ? (modelData.toolTip ?? "") : ""
            active: index === strip.currentIndex
            tabStrip: strip

            onClicked: strip.activateRequested(index)
            onCloseRequested: strip.closeRequested(index)
            onContextMenuRequested: strip.contextMenuRequested(index)
            onDragStarted: (sceneX, sceneY) => strip.beginTabDrag(index, sceneX, sceneY)
            onDragMoved: (sceneX, sceneY) => strip.moveTabDrag(sceneX, sceneY)
            onDragFinished: (sceneX, sceneY) => strip.finishTabDrag(sceneX, sceneY)
            onDragCanceled: strip.endTabDrag()
        }
    }

    // The dragged tab, under the pointer while it stays over the strip.
    TabStripButton {
        visible: strip.dragSourceIndex >= 0 && !strip.dragDetached
        enabled: false
        x: strip.dragPointerX - strip.dragGrabOffsetX
        y: strip.dragPointerY - strip.dragGrabOffsetY
        z: 2
        width: strip.dragTargetIndex >= 0 ? strip.tabWidth(strip.dragTargetIndex) : 0
        opacity: 0.9
        title: strip.dragTab ? (strip.dragTab.title ?? "") : ""
        modified: strip.dragTab ? (strip.dragTab.modified ?? false) : false
        active: strip.dragTabActive
    }

    // Outside the strip the tab follows the pointer in a frameless window of
    // its own, so it shows over other windows and the desktop.
    Loader {
        active: strip.dragDetached

        sourceComponent: Window {
            flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowTransparentForInput | Qt.WindowDoesNotAcceptFocus
            color: "transparent"
            visible: true
            x: strip.dragGlobalX - strip.dragGrabOffsetX
            y: strip.dragGlobalY - strip.dragGrabOffsetY
            width: previewTab.width
            height: previewTab.height

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: systemPalette.window
                opacity: 0.92
            }

            TabStripButton {
                id: previewTab

                enabled: false
                width: 220
                title: strip.dragTab ? (strip.dragTab.title ?? "") : ""
                modified: strip.dragTab ? (strip.dragTab.modified ?? false) : false
                active: true
            }
        }
    }

    T.AbstractButton {
        id: addButton

        y: (Math.max(40, strip.baseSafeTop) - height) / 2
        z: 1
        width: 30
        height: 30
        anchors.right: strip.right
        anchors.rightMargin: strip.trailingInset + 8
        hoverEnabled: true

        Accessible.name: qsTr("New tab")
        onClicked: strip.addRequested()

        background: Rectangle {
            radius: width / 2
            color: addButton.hovered ? Qt.rgba(systemPalette.windowText.r, systemPalette.windowText.g, systemPalette.windowText.b, addButton.down ? 0.18 : 0.12) : "transparent"
        }

        // The +, two strokes.
        contentItem: Item {
            Repeater {
                model: [0, 90]

                Rectangle {
                    required property int modelData

                    anchors.centerIn: parent
                    width: 12
                    height: 1.5
                    radius: 0.75
                    rotation: modelData
                    color: systemPalette.windowText
                    opacity: 0.8
                }
            }
        }
    }
}
