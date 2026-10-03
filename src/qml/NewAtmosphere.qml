import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

CutiePage {
    id: newAtmospherePage
    property url wallpaperUrl: ""
    property string themeName: ""
    property color primaryColor: "#cccccc"
    property color secondaryColor: "#999999"
    property color accentColor: "#666666"
    property color textColorValue: "#000000"
    property string variantValue: "light"
    property string errorText: ""
    property bool pickingColor: false
    property string editingField: ""
    property real pickHue: 0
    property real pickSat: 1
    property real pickVal: 1
    readonly property color pickedColor: Qt.hsva(pickHue, pickSat, pickVal, 1)
    readonly property int cardPadding: 20

    function applyExtractedPalette(palette) {
        if (!palette || !palette.primaryColor)
            return
        primaryColor = palette.primaryColor
        secondaryColor = palette.secondaryColor
        accentColor = palette.accentColor
        textColorValue = palette.textColor
        variantValue = palette.variant
    }
    function beginPick(field) {
        var c = newAtmospherePage[field]
        editingField = field
        pickHue = Math.max(0, c.hsvHue)
        pickSat = c.hsvSaturation
        pickVal = c.hsvValue
        pickingColor = true
    }
    function setPickedFromHex(hex) {
        if (!/^#[0-9a-fA-F]{6}$/.test(hex)) return
        var c = Qt.color(hex)
        pickHue = Math.max(0, c.hsvHue)
        pickSat = c.hsvSaturation
        pickVal = c.hsvValue
    }

    component PopupButton: CutieButton {
        property bool primary: false
        Layout.fillWidth: true
        Layout.preferredWidth: 0
        implicitHeight: 50
        background: Rectangle {
            radius: 8
            color: primary ? Atmosphere.primaryColor : "transparent"
            border.color: primary ? Atmosphere.primaryColor : Atmosphere.secondaryAlphaColor
            border.width: 2
            opacity: parent.enabled ? 1.0 : 0.4
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: pageContent.implicitHeight + 40
        clip: true
        ColumnLayout {
            id: pageContent
            x: 20
            width: parent.width - 40
            spacing: 14
            CutiePageHeader {
                title: qsTr("New Atmosphere")
                Layout.fillWidth: true
            }
            // ── Form ─────────────────────────────────────────────────
            ColumnLayout {
                visible: !newAtmospherePage.pickingColor
                Layout.fillWidth: true
                spacing: 14

                CutieLabel {
                    text: qsTr("New Atmosphere")
                    font.pixelSize: 24
                    font.weight: Font.Black
                }

                CutieTextField {
                    Layout.fillWidth: true
                    placeholderText: qsTr("Theme name")
                    onTextEdited: newAtmospherePage.themeName = text
                }

                // Wallpaper picker / preview
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160
                    radius: 12
                    color: Qt.rgba(0, 0, 0, 0.15)
                    border.color: Atmosphere.textColor
                    border.width: 1
                    opacity: newAtmospherePage.wallpaperUrl == "" ? 0.8 : 1.0

                    Image {
                        id: previewImage
                        anchors.fill: parent
                        anchors.margins: 1
                        source: newAtmospherePage.wallpaperUrl
                        fillMode: Image.PreserveAspectCrop
                        visible: newAtmospherePage.wallpaperUrl != ""
                        asynchronous: true
                    }

                    CutieLabel {
                        anchors.centerIn: parent
                        visible: newAtmospherePage.wallpaperUrl == ""
                        text: qsTr("Tap to select wallpaper")
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: wallpaperFileDialog.open()
                    }
                }

                // Colour swatches - populated from extraction, each tappable
                // to open the colour picker and override the value.
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    visible: newAtmospherePage.wallpaperUrl != ""

                    Repeater {
                        model: [
                            { label: qsTr("Primary"),   key: "primaryColor" },
                            { label: qsTr("Secondary"), key: "secondaryColor" },
                            { label: qsTr("Accent"),    key: "accentColor" },
                            { label: qsTr("Text"),      key: "textColorValue" }
                        ]

                        delegate: ColumnLayout {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 0
                            spacing: 6

                            // Outer ring matches the theme tile border
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 52
                                height: 52
                                radius: 26
                                color: "transparent"
                                border.color: Atmosphere.textColor
                                border.width: 1
                                opacity: 0.9

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 42
                                    height: 42
                                    radius: 21
                                    color: newAtmospherePage[modelData.key]
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: newAtmospherePage.beginPick(modelData.key)
                                }
                            }

                            CutieLabel {
                                text: modelData.label
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                CutieLabel {
                    visible: newAtmospherePage.errorText !== ""
                    text: newAtmospherePage.errorText
                    color: "#ff5555"
                    font.pixelSize: 14
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    PopupButton {
                        text: qsTr("Cancel")
                        onClicked: mainWindow.pageStack.pop()
                    }

                    PopupButton {
                        primary: true
                        text: qsTr("Save")
                        enabled: newAtmospherePage.wallpaperUrl != "" && newAtmospherePage.themeName.length > 0
                        onClicked: {
                            var colors = {
                                "variant": newAtmospherePage.variantValue,
                                "primaryColor": newAtmospherePage.primaryColor.toString(),
                                "secondaryColor": newAtmospherePage.secondaryColor.toString(),
                                "accentColor": newAtmospherePage.accentColor.toString(),
                                "textColor": newAtmospherePage.textColorValue.toString(),
                                "primaryAlphaColor": "#80" + newAtmospherePage.primaryColor.toString().substring(1),
                                "secondaryAlphaColor": "#65" + newAtmospherePage.secondaryColor.toString().substring(1)
                            }
                            var ok = Atmosphere.saveAtmosphere(
                                newAtmospherePage.themeName,
                                newAtmospherePage.wallpaperUrl,
                                colors
                            )
                            if (ok) {
                                mainWindow.pageStack.pop()
                            } else {
                                newAtmospherePage.errorText = qsTr("Couldn't save - try a different name.")
                            }
                        }
                    }
                }
            }

            // ── Colour picker ────────────────────────────────────────
            ColumnLayout {
                visible: newAtmospherePage.pickingColor
                Layout.fillWidth: true
                spacing: 14

                CutieLabel {
                    text: qsTr("Pick a colour")
                    font.pixelSize: 24
                    font.weight: Font.Black
                }

                // Saturation (x) / brightness (y) square for the current hue
                Rectangle {
                    id: svBox
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    radius: 12
                    clip: true
                    color: Qt.hsva(newAtmospherePage.pickHue, 1, 1, 1)
                    border.color: Atmosphere.textColor
                    border.width: 1

                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#FFFFFFFF" }
                            GradientStop { position: 1.0; color: "#00FFFFFF" }
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#00000000" }
                            GradientStop { position: 1.0; color: "#FF000000" }
                        }
                    }

                    // Handle
                    Rectangle {
                        x: newAtmospherePage.pickSat * svBox.width - width / 2
                        y: (1 - newAtmospherePage.pickVal) * svBox.height - height / 2
                        width: 22
                        height: 22
                        radius: 11
                        color: newAtmospherePage.pickedColor
                        border.color: "white"
                        border.width: 3
                    }

                    MouseArea {
                        anchors.fill: parent
                        function pick(m) {
                            newAtmospherePage.pickSat = Math.max(0, Math.min(1, m.x / width))
                            newAtmospherePage.pickVal = 1 - Math.max(0, Math.min(1, m.y / height))
                        }
                        onPressed: (m) => pick(m)
                        onPositionChanged: (m) => pick(m)
                    }
                }

                // Hue strip
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
                        x: newAtmospherePage.pickHue * (hueBar.width - width)
                        anchors.verticalCenter: parent.verticalCenter
                        width: 22
                        height: 34
                        radius: 8
                        color: Qt.hsva(newAtmospherePage.pickHue, 1, 1, 1)
                        border.color: "white"
                        border.width: 3
                    }

                    MouseArea {
                        anchors.fill: parent
                        function pick(m) {
                            newAtmospherePage.pickHue = Math.max(0, Math.min(1, m.x / width))
                        }
                        onPressed: (m) => pick(m)
                        onPositionChanged: (m) => pick(m)
                    }
                }

                // Preview + hex entry
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

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
                            color: newAtmospherePage.pickedColor
                        }
                    }

                    CutieTextField {
                        id: hexField
                        Layout.fillWidth: true
                        maximumLength: 7
                        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                        text: newAtmospherePage.pickedColor.toString().toUpperCase()
                        onEditingFinished: newAtmospherePage.setPickedFromHex(text)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    PopupButton {
                        text: qsTr("Back")
                        onClicked: newAtmospherePage.pickingColor = false
                    }

                    PopupButton {
                        primary: true
                        text: qsTr("Done")
                        onClicked: {
                            newAtmospherePage.setPickedFromHex(hexField.text)
                            newAtmospherePage[newAtmospherePage.editingField] = newAtmospherePage.pickedColor
                            newAtmospherePage.pickingColor = false
                        }
                    }
                }
            }
        }
    }

    FileDialog {
        id: wallpaperFileDialog
        title: qsTr("Select wallpaper")
        nameFilters: [qsTr("Image files") + " (*.jpg *.jpeg *.png *.bmp)"]
        onAccepted: {
            newAtmospherePage.wallpaperUrl = selectedFile
            newAtmospherePage.applyExtractedPalette(Atmosphere.extractPalette(selectedFile))
        }
    }
}
