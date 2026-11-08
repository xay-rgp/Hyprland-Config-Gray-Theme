import QtQuick
import "../../theme"
import "../../state"
import "../../components"

Row {
    id: root
    readonly property bool statusHovered: status.hovered
    spacing: 8
    height: 24

    RightContent {
        id: status
        anchors.verticalCenter: parent.verticalCenter
    }

    Row {
        spacing: 0
        anchors.verticalCenter: parent.verticalCenter
        Tray {
            id: tray
            visible: implicitWidth > 0
            width: Math.min(implicitWidth, Math.max(24,
                Theme.rNotchMaxWidth - Theme.notchPadding * 2 - status.implicitWidth - settings.implicitWidth - 8))
            height: 24
        }
        IconButton {
            id: settings
            anchors.verticalCenter: parent.verticalCenter
            glyph: "\uf013"
            size: 24
            // Keep the full bar height but remove horizontal icon padding.
            implicitWidth: 16
            glyphSize: 16
            active: ShellState.controlCenterOpen && ShellState.ccPage === "appearance"
            onActivated: {
                if (active) ShellState.closeAll()
                else ShellState.showPage("appearance")
            }
        }
    }
}
