import QtQuick
import QtQuick.Controls
import "../theme"
import "../services"
import "../state"
import "../components"

Item {
    id: root
    property bool active: false
    property var player: MediaService.player
    readonly property bool playing: !!player && player.isPlaying
    readonly property real duration: player && player.lengthSupported ? Math.max(0, player.length) : 0
    readonly property real position: player && player.positionSupported ? Math.max(0, player.position) : 0
    readonly property bool seekable: !!player && player.canSeek && player.positionSupported && duration > 0
    property bool scrubbing: false
    property real scrubFraction: 0
    readonly property real fraction: scrubbing ? scrubFraction : (duration > 0 ? Math.min(1, position / duration) : 0)
    implicitWidth: 420
    implicitHeight: content.implicitHeight + 40

    onPlayerChanged: scrubbing = false
    onActiveChanged: if (!active) scrubbing = false
    onSeekableChanged: if (!seekable) scrubbing = false
    Connections {
        target: root.player
        ignoreUnknownSignals: true
        function onPostTrackChanged() { root.scrubbing = false }
    }
    function timeLabel(seconds) {
        seconds = Math.max(0, Math.floor(seconds))
        const hours = Math.floor(seconds / 3600)
        const minutes = Math.floor(seconds / 60) % 60
        return (hours ? hours + ":" + String(minutes).padStart(2, "0") : String(minutes))
            + ":" + String(seconds % 60).padStart(2, "0")
    }
    function seekTo(fraction) {
        if (root.seekable) root.player.position = Math.min(1, Math.max(0, fraction)) * root.duration
    }
    Timer {
        interval: 500
        repeat: true
        running: root.active && root.playing && !!root.player && root.player.positionSupported
        onTriggered: root.player.positionChanged()
    }

    Column {
        id: content
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
        spacing: 16
        Row {
            width: parent.width
            Text {
                width: parent.width - 30
                text: root.player ? root.player.identity : "Now playing"
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: Theme.subtext0
                font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
            }
            IconButton { glyph: "\uf00d"; size: 26; onActivated: ShellState.closeAll() }
        }
        Cover {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 236
            height: width
            radius: 18
            source: root.player ? root.player.trackArtUrl : ""
        }
        Column {
            width: parent.width
            spacing: 6
            Text {
                width: parent.width
                text: root.player ? (root.player.trackTitle || "Unknown track") : "Nothing playing"
                textFormat: Text.PlainText
                color: Theme.text
                font { family: Theme.fontFamily; pixelSize: 18; bold: true }
                elide: Text.ElideRight
                maximumLineCount: 1
            }
            Text {
                width: parent.width
                text: root.player ? (root.player.trackArtist || root.player.trackAlbum || "Unknown artist")
                                  : "Start audio in a media player or browser."
                textFormat: Text.PlainText
                color: Theme.subtext0
                font { family: Theme.fontFamily; pixelSize: Theme.fontSize }
                elide: Text.ElideRight
            }
        }
        Column {
            width: parent.width
            spacing: 2
            Item {
                id: timeline
                width: parent.width
                height: 36
                property real phase: 0
                property real amplitude: root.playing ? 4 : 0
                Behavior on amplitude { NumberAnimation { duration: 220 } }
                onAmplitudeChanged: wave.requestPaint()
                onPhaseChanged: wave.requestPaint()
                Timer {
                    interval: 33
                    repeat: true
                    running: root.active && root.playing
                    onTriggered: timeline.phase = (timeline.phase + 0.18) % (Math.PI * 2)
                }
                Canvas {
                    id: wave
                    anchors.fill: parent
                    readonly property real progress: root.fraction
                    readonly property color ink: Theme.text
                    readonly property color trackColor: Theme.surface2
                    onProgressChanged: requestPaint()
                    onInkChanged: requestPaint()
                    onTrackColorChanged: requestPaint()
                    onWidthChanged: requestPaint()
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.reset()
                        const start = 5, end = width - 5, y = height / 2
                        const tip = start + (end - start) * progress
                        ctx.lineWidth = 3
                        ctx.lineCap = "round"
                        ctx.strokeStyle = trackColor
                        ctx.beginPath(); ctx.moveTo(start, y); ctx.lineTo(end, y); ctx.stroke()
                        // With no reported duration, the wave is decorative rather than a false progress value.
                        const waveEnd = root.duration > 0 ? tip : (root.player ? end : start)
                        ctx.strokeStyle = ink
                        ctx.beginPath()
                        for (let x = start; x <= waveEnd; x += 1) {
                            const taper = Math.min(1, (x - start) / 8, (waveEnd - x) / 8)
                            const dy = Math.sin((x - start) * Math.PI / 12 - timeline.phase) * timeline.amplitude * taper
                            if (x === start) ctx.moveTo(x, y + dy)
                            else ctx.lineTo(x, y + dy)
                        }
                        ctx.stroke()
                        if (root.duration > 0) {
                            ctx.fillStyle = ink
                            ctx.beginPath(); ctx.roundedRect(tip - 2, y - 9, 4, 18, 2, 2); ctx.fill()
                        }
                    }
                }
                MouseArea {
                    id: seekMouse
                    anchors.fill: parent
                    enabled: root.seekable
                    cursorShape: Qt.PointingHandCursor
                    function update(x) { root.scrubFraction = Math.max(0, Math.min(1, (x - 5) / (width - 10))) }
                    onPressed: function (mouse) { update(mouse.x); root.scrubbing = true }
                    onPositionChanged: function (mouse) { if (pressed && root.scrubbing) update(mouse.x) }
                    onReleased: {
                        if (root.scrubbing) root.seekTo(root.scrubFraction)
                        root.scrubbing = false
                    }
                    onCanceled: root.scrubbing = false
                }
            }
            Row {
                width: parent.width
                Text {
                    width: parent.width / 2
                    text: root.timeLabel(root.scrubbing ? root.scrubFraction * root.duration : root.position)
                    color: Theme.subtext0
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeSmall }
                }
                Text {
                    width: parent.width / 2
                    horizontalAlignment: Text.AlignRight
                    text: root.duration > 0 ? root.timeLabel(root.duration) : "—"
                    color: Theme.subtext0
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSizeSmall }
                }
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 24
            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\uf048"; size: 44; glyphSize: 20
                enabled: !!root.player && root.player.canGoPrevious
                opacity: enabled ? 1 : 0.3
                Accessible.name: "Previous track"
                ToolTip.visible: hovered
                ToolTip.text: "Previous track"
                onActivated: root.player.previous()
            }
            IconButton {
                glyph: root.playing ? "\uf04c" : "\uf04b"
                size: 60; glyphSize: 22
                color: Theme.text
                glyphColor: Theme.base
                enabled: !!root.player && root.player.canTogglePlaying
                opacity: enabled ? 1 : 0.3
                Accessible.name: root.playing ? "Pause" : "Play"
                ToolTip.visible: hovered
                ToolTip.text: root.playing ? "Pause" : "Play"
                onActivated: root.player.togglePlaying()
            }
            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                glyph: "\uf051"; size: 44; glyphSize: 20
                enabled: !!root.player && root.player.canGoNext
                opacity: enabled ? 1 : 0.3
                Accessible.name: "Next track"
                ToolTip.visible: hovered
                ToolTip.text: "Next track"
                onActivated: root.player.next()
            }
        }
    }
}
