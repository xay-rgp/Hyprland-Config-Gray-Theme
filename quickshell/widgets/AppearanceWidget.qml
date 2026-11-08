pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"
import "../state"
import "../components"

Item {
    id: root
    property bool active: false
    property string message: ""
    implicitWidth: 380
    implicitHeight: content.implicitHeight + 36

    function apply(action) {
        if (worker.running) return
        root.message = ""
        worker.command = ["python3", Quickshell.shellDir + "/scripts/appearance.py", action]
        worker.running = true
        if (action === "wallpaper") ShellState.closeAll()
    }
    Process {
        id: worker
        stdout: StdioCollector {
            onStreamFinished: root.message = text.trim()
        }
        onExited: function (code) {
            if (code !== 0 && root.message === "") root.message = "Could not apply settings."
        }
    }
    Column {
        id: content
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 18 }
        spacing: 18
        Row {
            width: parent.width
            Text {
                width: parent.width - 34
                text: "Settings"
                color: Theme.text
                font { family: Theme.fontFamily; pixelSize: 20; bold: true }
            }
            IconButton { glyph: "\uf00d"; size: 26; onActivated: ShellState.closeAll() }
        }
        Rectangle {
            width: parent.width
            height: 48
            radius: 10
            color: wallMouse.containsMouse ? Theme.hover : Theme.surface
            Text {
                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                text: "Change wallpaper…"
                color: Theme.text
                font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
            }
            MouseArea {
                id: wallMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                enabled: !worker.running
                onClicked: root.apply("wallpaper")
            }
        }
        Rectangle {
            width: parent.width
            height: 48
            radius: 10
            color: updateMouse.containsMouse ? Theme.hover : Theme.surface
            Text {
                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                text: "Update desktop from GitHub…"
                color: Theme.text
                font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
            }
            MouseArea {
                id: updateMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Quickshell.execDetached(["bash", Quickshell.shellDir + "/scripts/update-desktop.sh", "--launch"])
                    ShellState.closeAll()
                }
            }
        }
        Text {
            width: parent.width
            text: "Updates desktop files and packages in a terminal."
            color: Theme.subtext0
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
        }
        Text {
            visible: root.message !== ""
            width: parent.width
            text: root.message
            wrapMode: Text.Wrap
            color: Theme.text
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
