pragma Singleton

import QtQuick 2.12

QtObject {
    readonly property color nav950: "#062649"
    readonly property color nav900: "#0A2F5E"
    readonly property color nav800: "#103C70"
    readonly property color primary700: "#084A8B"
    readonly property color primary600: "#0B5CAD"
    readonly property color primary100: "#DCEAFB"
    readonly property color primary050: "#EAF2FC"
    readonly property color canvas: "#F4F7FB"
    readonly property color surface: "#FFFFFF"
    readonly property color surfaceMuted: "#EEF3F8"
    readonly property color text900: "#14243A"
    readonly property color text700: "#344A63"
    readonly property color text600: "#596B82"
    readonly property color border: "#D7E1ED"
    readonly property color borderStrong: "#B9C9DA"
    readonly property color gold: "#B3883E"
    readonly property color goldLight: "#DFC17C"
    readonly property color teal: "#1C7F8F"
    readonly property color tealSoft: "#E4F2F4"
    readonly property color success: "#17805C"
    readonly property color successSoft: "#E5F4EE"
    readonly property color warning: "#9A651A"
    readonly property color warningSoft: "#FBF1DF"
    readonly property color danger: "#B63E49"
    readonly property color dangerSoft: "#FBEAEC"
    readonly property string uiFont: "Noto Sans CJK SC"
    readonly property string dataFont: "Noto Sans Mono"

    function iconSource(name) {
        return "qrc:/icons/" + name + ".svg"
    }
}
