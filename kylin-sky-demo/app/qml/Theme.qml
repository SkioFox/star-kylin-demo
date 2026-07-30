pragma Singleton
import QtQuick 2.12

QtObject {
    readonly property string uiFont: "Noto Sans CJK SC"
    readonly property string dataFont: "Noto Sans Mono"
    readonly property real textScale: 1.28

    // Sampled from the V2.1 prototype's terminal surfaces and signal states.
    readonly property color command: "#061426"
    readonly property color rail: "#072038"
    readonly property color railHover: "#071D34"
    readonly property color railActive: "#0A4773"
    readonly property color panelBlue: "#0A3050"
    readonly property color panelBlueDark: "#082A44"
    readonly property color signal: "#33D8E4"
    readonly property color signalSoft: "#0C3D60"
    readonly property color gold: "#E3B65B"
    readonly property color label: "#67DFE6"
    readonly property color labelMuted: "#C6D9E8"
    readonly property color accentText: label

    readonly property color canvas: "#071C31"
    readonly property color surface: "#092D4A"
    readonly property color surfaceSoft: "#071D34"
    readonly property color ink: "#F1F7FC"
    readonly property color muted: "#A6C5D8"
    readonly property color line: "#0A4773"
    readonly property color softLine: "#0C3150"
    readonly property color up: "#DF637B"
    readonly property color down: "#56D4B0"

    // Authentication intentionally keeps the bright, low-distraction form surface from V2.1.
    readonly property color loginSurface: "#FFFFFF"
    readonly property color loginInk: "#172B42"
    readonly property color loginMuted: "#5C6F84"
    readonly property color loginLine: "#BCCDDE"
    readonly property color loginAction: "#0A67B4"

    readonly property int shellRailHeight: 60
    readonly property int tabsHeight: 46
    readonly property int contextHeight: 40
    readonly property int sidebarWidth: 224
    readonly property int contentPadding: 16
    readonly property int controlHeight: 34
    readonly property int navigationRowHeight: 44
    readonly property int denseRowHeight: 36
    readonly property int dataRowHeight: 56
    readonly property int toolHeight: 36
}
