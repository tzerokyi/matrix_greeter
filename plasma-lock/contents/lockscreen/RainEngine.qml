import QtQuick

Item {
    id: engine
    property int quality: 2
    property real density: 0.90
    property real intensity: 1.0
    property bool animate: true
    readonly property bool software: GraphicsInfo.api === GraphicsInfo.Software
    readonly property bool shaderEnabled: !software && quality > 0

    Image {
        anchors.fill: parent
        source: "assets/fallback.png"
        fillMode: Image.PreserveAspectCrop
        smooth: true
        visible: !engine.shaderEnabled
    }

    ShaderEffect {
        id: effect
        anchors.fill: parent
        visible: engine.shaderEnabled
        blending: false
        property var glyphAtlas: Image {
            source: "assets/glyph-atlas.png"
            asynchronous: false
            cache: true
            smooth: false
            visible: false
        }
        property vector2d viewport: Qt.vector2d(width, height)
        property real clockSeconds: 0
        property real density: engine.density
        property real intensity: engine.intensity
        property real quality: engine.quality
        property real motion: engine.animate ? 1.0 : 0.0
        fragmentShader: "shaders/rain.frag.qsb"

        NumberAnimation on clockSeconds {
            from: 0
            to: 3600
            duration: 3600000
            loops: Animation.Infinite
            running: engine.shaderEnabled && engine.animate
        }
    }
}
