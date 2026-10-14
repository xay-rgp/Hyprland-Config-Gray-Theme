import QtQuick

QtObject {
  readonly property color bgBase: "#000000"
  readonly property color bgSurface: "#111111"
  readonly property color bgOverlay: "#88000000"
  readonly property color bgHover: "#1a1a1a"
  readonly property color bgSelected: "#222222"
  readonly property color bgBorder: "#2a2a2a"

  readonly property color textPrimary: "#ffffff"
  readonly property color textSecondary: "#d9d9d9"
  readonly property color textMuted: "#777777"

  readonly property color accentPrimary: "#ffffff"
  readonly property color accentCyan: "#ffffff"
  readonly property color accentGreen: "#ffffff"
  readonly property color accentOrange: "#ffffff"
  readonly property color accentRed: "#ffffff"

  readonly property color urgencyLow: textMuted
  readonly property color urgencyNormal: accentPrimary
  readonly property color urgencyCritical: accentRed
  readonly property color batteryGood: accentGreen
  readonly property color batteryWarning: accentOrange
  readonly property color batteryCritical: accentRed

}
