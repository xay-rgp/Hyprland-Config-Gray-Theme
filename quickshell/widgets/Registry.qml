// Widgets available from the middle island.
pragma Singleton
import QtQuick

QtObject {
    id: root
    readonly property var widgets: [
        { id: "stats", name: "Machine Stats", icon: "\u{f0128}", source: "StatsWidget.qml" },
        { id: "appearance", name: "Settings", icon: "\uf013", source: "AppearanceWidget.qml" }
    ]
    readonly property var pickable: widgets
    readonly property var home: widgets[0]
    function find(id) {
        return root.widgets.find(function (w) { return w.id === (id === "home" ? "stats" : id) }) || null
    }
}
