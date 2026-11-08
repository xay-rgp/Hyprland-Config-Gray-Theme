import QtQuick
import "../theme"

Canvas {
    id: root

    property int size: 15
    property bool mirrored: false

    width: size
    height: size
    transform: Scale { origin.x: root.size / 2; xScale: root.mirrored ? -1 : 1 }

    onSizeChanged: requestPaint()

    Connections {
        target: Theme
        function onBarBgChanged() { root.requestPaint() }
    }

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        const r = root.size
        ctx.beginPath()
        ctx.moveTo(0, 0)
        ctx.lineTo(r, 0)
        ctx.lineTo(r, r)
        ctx.arcTo(r, 0, 0, 0, r)
        ctx.closePath()
        ctx.fillStyle = Theme.barBg
        ctx.fill()
    }
}
