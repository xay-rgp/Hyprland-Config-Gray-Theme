// Compact media pill; click to open artwork, progress and transport controls.
import QtQuick
import "../../theme"
import "../../state"
import "../../services"

Rectangle {
    id: root

    readonly property string track: MediaService.label
        || (MediaService.player ? MediaService.player.identity : "")

    readonly property string text: MediaService.playing ? (track || "Audio playing")
        : MediaService.active ? "Paused · " + track
        : "Nothing playing"

    // Round up and leave a small text buffer so integer bar sizing cannot
    // clip the final character of short labels.
    implicitWidth: Math.min(260, Math.ceil(label.implicitWidth) + note.width + 6 + 18 + 2)
    implicitHeight: 20
    radius: height / 2
    color: Theme.surface0
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.10)

    Text {
        id: note
        anchors.left: parent.left
        anchors.leftMargin: 9
        anchors.verticalCenter: parent.verticalCenter
        width: 12
        text: "\uf001"
        color: MediaService.playing ? Theme.text : Theme.subtext0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: label
        anchors.left: note.right
        anchors.leftMargin: 6
        anchors.right: parent.right
        anchors.rightMargin: 9
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        textFormat: Text.PlainText
        elide: Text.ElideRight
        maximumLineCount: 1
        color: MediaService.playing ? Theme.text : Theme.subtext0
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }
    HoverHandler { cursorShape: Qt.PointingHandCursor }
    TapHandler {
        onTapped: {
            if (ShellState.controlCenterOpen && ShellState.ccPage === "media") ShellState.closeAll()
            else ShellState.showPage("media")
        }
    }
}
