import QtQuick
import QtQuick.Controls as Controls

Controls.Button {
    id: action
    property color accent: "#87ffb0"
    property bool primary: false
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    implicitWidth: Math.max(primary ? 129 : 72, label.implicitWidth + (primary ? 36 : 18))
    implicitHeight: 36
    padding: 0
    contentItem: Text {
        id: label
        text: action.text
        color: !action.enabled ? "#466250" : (action.primary ? "#e4ffee" : (action.hovered || action.activeFocus ? action.accent : "#95bca0"))
        font.family: "DejaVu Sans Mono"; font.pixelSize: 10
        font.bold: action.primary || action.hovered || action.activeFocus
        font.letterSpacing: 0.5
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    background: Rectangle {
        color: !action.enabled ? (action.primary ? "#0b1f12" : "transparent") :
               (action.down ? "#1c5b34" : action.primary ? "#0e3922" : (action.hovered || action.activeFocus ? "#0a2616" : "transparent"))
        border.width: action.primary || action.activeFocus ? 1 : 0
        border.color: action.activeFocus ? "#d8ffe2" : "#3eaa65"
        radius: 0
    }
}
