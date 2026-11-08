import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../state"
import "../widgets"
import "../modules/Left"
import "../shapes"

PanelWindow {
    id: root
    property bool active: false
    property var barWindow: null
    readonly property real collapsedWidth: barWindow ? barWindow.lWidth : 180
    readonly property int contentTop: Theme.borderWidth + 4
    readonly property bool open: active && ShellState.controlCenterOpen && ShellState.ccPage === "media"
    property real reveal: open ? 1 : 0
    Behavior on reveal {
        NumberAnimation { duration: Theme.ccMorphDuration; easing.type: Easing.OutCubic }
    }
    visible: open || reveal > 0
    mask: Region {
        width: root.open ? root.width : 0
        height: root.open ? root.height : 0
    }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Shortcut {
        sequence: "Escape"
        enabled: root.open
        onActivated: ShellState.closeAll()
    }
    MouseArea {
        anchors.fill: parent
        enabled: root.open
        onPressed: function (mouse) {
            mouse.accepted = !card.contains(mapToItem(card, mouse.x, mouse.y))
        }
        onClicked: ShellState.closeAll()
    }
    Rectangle {
        id: card
        x: 0
        readonly property real expandedWidth: Math.min(media.implicitWidth, root.width - Theme.borderWidth)
        readonly property real expandedHeight: Math.min(media.implicitHeight + root.contentTop, root.height - 40)
        y: 0
        width: root.collapsedWidth + (expandedWidth - root.collapsedWidth) * root.reveal
        height: Theme.notchHeight + (expandedHeight - Theme.notchHeight) * root.reveal
        bottomRightRadius: Theme.notchRadius + (Theme.ccRadius - Theme.notchRadius) * root.reveal
        color: Theme.barBg
        clip: true
        NowPlaying {
            x: Theme.notchPadding
            y: (Theme.notchHeight - height) / 2
            width: root.collapsedWidth - Theme.notchPadding * 2
            height: implicitHeight
            opacity: Math.max(0, 1 - root.reveal * 3)
            visible: opacity > 0
        }
        Flickable {
            y: root.contentTop
            width: card.expandedWidth
            height: card.expandedHeight - root.contentTop
            enabled: root.open
            opacity: Math.max(0, (root.reveal - 0.15) / 0.85)
            contentWidth: width
            contentHeight: media.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            MediaWidget {
                id: media
                width: parent.width
                height: implicitHeight
                active: root.open
            }
        }
    }

    // Mirror the right menu's concave joins into the top strip and left frame.
    ConcaveFillet { x: card.width; y: Theme.borderWidth; size: Theme.notchRadius; mirrored: true }
    ConcaveFillet { x: Theme.borderWidth; y: card.height; size: Theme.cornerRadius; mirrored: true }
}
