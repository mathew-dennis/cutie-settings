import Cutie
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: colorPicker

    property color initialColor: "#cccccc"
    property real hue: 0
    property real saturation: 1
    property real brightness: 1
    readonly property color selectedColor: Qt.hsva(hue, saturation, brightness, 1)

    signal accepted(color selectedColor)
    signal cancelled()

    implicitWidth: 320
    implicitHeight: 430
    radius: 16
    color: Atmosphere.primaryColor
    border.color: Atmosphere.textColor
    border.width: 1

    onVisibleChanged: {
        if (visible)
            setFromColor(initialColor)
    }

    function setFromColor(value) {
        hue = Math.max(0, value.hsvHue)
        saturation = value.hsvSaturation
        brightness = value.hsvValue
    }

    function setFromHex(value) {
        if (!/^#[0-9a-fA-F]{6}$/.test(value))
            return
        setFromColor(Qt.color(value))
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius
        color: Atmosphere.secondaryAlphaColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        CutieLabel {
            text: qsTr("Pick a colour")
            font.pixelSize: 22
            font.weight: Font.Black
            Layout.fillWidth: true
        }

        Rectangle {
            id: saturationBox
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            radius: 12
            clip: true
            color: Qt.hsva(colorPicker.hue, 1, 1, 1)
            border.color: Atmosphere.textColor
            border.width: 1

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "#FFFFFFFF" }
                    GradientStop { position: 1; color: "#00FFFFFF" }
                }
            }
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0; color: "#00000000" }
                    GradientStop { position: 1; color: "#FF000000" }
                }
            }
            Rectangle {
                x: colorPicker.saturation * saturationBox.width - width / 2
                y: (1 - colorPicker.brightness) * saturationBox.height - height / 2
                width: 22
                height: 22
                radius: 11
                color: colorPicker.selectedColor
                border.color: "white"
                border.width: 3
            }
            MouseArea {
                anchors.fill: parent
                function pick(mouse) {
                    colorPicker.saturation = Math.max(0, Math.min(1, mouse.x / width))
                    colorPicker.brightness = 1 - Math.max(0, Math.min(1, mouse.y / height))
                }
                onPressed: (mouse) => pick(mouse)
                onPositionChanged: (mouse) => pick(mouse)
            }
        }

        Rectangle {
            id: hueBar
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            radius: 14
            border.color: Atmosphere.textColor
            border.width: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.000; color: "#FF0000" }
                GradientStop { position: 0.167; color: "#FFFF00" }
                GradientStop { position: 0.333; color: "#00FF00" }
                GradientStop { position: 0.500; color: "#00FFFF" }
                GradientStop { position: 0.667; color: "#0000FF" }
                GradientStop { position: 0.833; color: "#FF00FF" }
                GradientStop { position: 1.000; color: "#FF0000" }
            }
            Rectangle {
                x: colorPicker.hue * (hueBar.width - width)
                anchors.verticalCenter: parent.verticalCenter
                width: 22
                height: 34
                radius: 8
                color: Qt.hsva(colorPicker.hue, 1, 1, 1)
                border.color: "white"
                border.width: 3
            }
            MouseArea {
                anchors.fill: parent
                function pick(mouse) {
                    colorPicker.hue = Math.max(0, Math.min(1, mouse.x / width))
                }
                onPressed: (mouse) => pick(mouse)
                onPositionChanged: (mouse) => pick(mouse)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                width: 44
                height: 44
                radius: 22
                color: "transparent"
                border.color: Atmosphere.textColor
                border.width: 1
                Rectangle {
                    anchors.centerIn: parent
                    width: 34
                    height: 34
                    radius: 17
                    color: colorPicker.selectedColor
                }
            }

            CutieTextField {
                id: hexField
                Layout.fillWidth: true
                maximumLength: 7
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                text: colorPicker.selectedColor.toString().toUpperCase()
                onEditingFinished: colorPicker.setFromHex(text)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            CutieButton {
                Layout.fillWidth: true
                text: qsTr("Back")
                onClicked: colorPicker.cancelled()
            }
            CutieButton {
                Layout.fillWidth: true
                text: qsTr("Done")
                onClicked: {
                    colorPicker.setFromHex(hexField.text)
                    colorPicker.accepted(colorPicker.selectedColor)
                }
            }
        }
    }
}
