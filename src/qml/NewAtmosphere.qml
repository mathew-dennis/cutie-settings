import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Popup {
    id: newAtmospherePopup
    anchors.centerIn: parent
    width: Math.min(parent ? parent.width - 32 : 368, 420)
    height: Math.max(0, Math.min(pageContent.implicitHeight + padding * 2, parent ? parent.height - 40 : 700))
    modal: true
    focus: true
    padding: 12
    closePolicy: Popup.CloseOnEscape
    property url wallpaperUrl: ""
    property string themeName: ""
    property color primaryColor: "#cccccc"
    property color secondaryColor: "#999999"
    property color accentColor: "#666666"
    property color textColorValue: "#000000"
    property string variantValue: "light"
    property string errorText: ""
    property bool pickingColor: false
    property bool pickingFile: false
    property string editingField: ""
    property real pickHue: 0
    property real pickSat: 1
    property real pickVal: 1
    readonly property color pickedColor: Qt.hsva(pickHue, pickSat, pickVal, 1)
    readonly property int cardPadding: 20

    // Live preview: once a wallpaper is chosen, the popup fades to the new palette
    readonly property bool previewing: wallpaperUrl != ""
    readonly property int previewDuration: 1200
    property color uiPrimary: previewing ? primaryColor : Atmosphere.primaryColor
    property color uiSecondaryAlpha: previewing ? Qt.rgba(secondaryColor.r, secondaryColor.g, secondaryColor.b, 0x65 / 255) : Atmosphere.secondaryAlphaColor
    property color uiText: previewing ? textColorValue : Atmosphere.textColor
    Behavior on uiPrimary { ColorAnimation { duration: newAtmospherePopup.previewDuration; easing.type: Easing.InOutQuad } }
    Behavior on uiSecondaryAlpha { ColorAnimation { duration: newAtmospherePopup.previewDuration; easing.type: Easing.InOutQuad } }
    Behavior on uiText { ColorAnimation { duration: newAtmospherePopup.previewDuration; easing.type: Easing.InOutQuad } }

    Overlay.modal: Rectangle {
        color: "#99000000"
    }

    background: Rectangle {
        radius: 16
        color: newAtmospherePopup.uiPrimary
        border.color: newAtmospherePopup.uiText
        border.width: 1
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: newAtmospherePopup.uiSecondaryAlpha
        }
    }

    function reset() {
        wallpaperUrl = ""
        themeName = ""
        errorText = ""
        pickingColor = false
        pickingFile = false
        themeNameField.text = ""
        primaryColor = "#cccccc"
        secondaryColor = "#999999"
        accentColor = "#666666"
        textColorValue = "#000000"
        variantValue = "light"
    }

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
        var c = newAtmospherePopup[field]
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
            color: primary ? newAtmospherePopup.uiPrimary : "transparent"
            border.color: primary ? newAtmospherePopup.uiPrimary : newAtmospherePopup.uiSecondaryAlpha
            border.width: 2
            opacity: parent.enabled ? 1.0 : 0.4
        }
    }

    contentItem: Flickable {
        implicitHeight: Math.min(pageContent.implicitHeight, 620)
        contentHeight: pageContent.implicitHeight
        clip: true
        ColumnLayout {
            id: pageContent
            width: parent.width
            spacing: 14
            // ── Form ─────────────────────────────────────────────────
            ColumnLayout {
                visible: !newAtmospherePopup.pickingColor && !newAtmospherePopup.pickingFile
                Layout.fillWidth: true
                spacing: 14

                CutieLabel {
                    text: qsTr("New Atmosphere")
                    color: newAtmospherePopup.uiText
                    font.pixelSize: 24
                    font.weight: Font.Black
                }

                CutieTextField {
                    id: themeNameField
                    color: newAtmospherePopup.uiText
                    placeholderTextColor: Qt.alpha(newAtmospherePopup.uiText, 0.6)
                    Layout.fillWidth: true
                    placeholderText: qsTr("Theme name")
                    onTextChanged: {
                        newAtmospherePopup.themeName = text
                        newAtmospherePopup.errorText = ""
                    }
                }

                // Wallpaper picker / preview
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160
                    radius: 12
                    color: Qt.rgba(0, 0, 0, 0.15)
                    border.color: newAtmospherePopup.uiText
                    border.width: 1
                    opacity: newAtmospherePopup.wallpaperUrl == "" ? 0.8 : 1.0

                    Image {
                        id: previewImage
                        anchors.fill: parent
                        anchors.margins: 1
                        source: newAtmospherePopup.wallpaperUrl
                        fillMode: Image.PreserveAspectCrop
                        visible: newAtmospherePopup.wallpaperUrl != ""
                        asynchronous: true
                    }

                    CutieLabel {
                        anchors.centerIn: parent
                        visible: newAtmospherePopup.wallpaperUrl == ""
                        text: qsTr("Tap to select wallpaper")
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: newAtmospherePopup.pickingFile = true
                    }
                }

                // Colour swatches - populated from extraction, each tappable
                // to open the colour picker and override the value.
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    visible: newAtmospherePopup.wallpaperUrl != ""

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
                                border.color: newAtmospherePopup.uiText
                                border.width: 1
                                opacity: 0.9

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 42
                                    height: 42
                                    radius: 21
                                    color: newAtmospherePopup[modelData.key]
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (modelData.key === "textColorValue") {
                                            var toDark = newAtmospherePopup.textColorValue.toString() === "#000000"
                                            newAtmospherePopup.textColorValue = toDark ? "#ffffff" : "#000000"
                                            newAtmospherePopup.variantValue = toDark ? "dark" : "light"
                                        } else {
                                            newAtmospherePopup.beginPick(modelData.key)
                                        }
                                    }
                                }
                            }

                            CutieLabel {
                                text: modelData.label
                                color: newAtmospherePopup.uiText
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }

                CutieLabel {
                    visible: newAtmospherePopup.errorText !== ""
                    text: newAtmospherePopup.errorText
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
                        onClicked: newAtmospherePopup.close()
                    }

                    PopupButton {
                        primary: true
                        text: qsTr("Save")
                        enabled: newAtmospherePopup.wallpaperUrl != "" && themeNameField.text.trim().length > 0
                        onClicked: {
                            var colors = {
                                "variant": newAtmospherePopup.variantValue,
                                "primaryColor": newAtmospherePopup.primaryColor.toString(),
                                "secondaryColor": newAtmospherePopup.secondaryColor.toString(),
                                "accentColor": newAtmospherePopup.accentColor.toString(),
                                "textColor": newAtmospherePopup.textColorValue.toString(),
                                "primaryAlphaColor": "#80" + newAtmospherePopup.primaryColor.toString().substring(1),
                                "secondaryAlphaColor": "#65" + newAtmospherePopup.secondaryColor.toString().substring(1)
                            }
                            try {
                                var ok = Atmosphere.saveAtmosphere(
                                    themeNameField.text.trim(),
                                    newAtmospherePopup.wallpaperUrl,
                                    colors
                                )
                                if (ok) {
                                    newAtmospherePopup.close()
                                } else {
                                    newAtmospherePopup.errorText = qsTr("Couldn't save - check the name and try again.")
                                }
                            } catch (error) {
                                console.warn("Atmosphere save failed:", error)
                                newAtmospherePopup.errorText = qsTr("Couldn't save this atmosphere.")
                            }
                        }
                    }
                }
            }

            AtmosphereFilePicker {
                visible: newAtmospherePopup.pickingFile
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                onAccepted: function(fileUrl) {
                    newAtmospherePopup.wallpaperUrl = fileUrl
                    newAtmospherePopup.applyExtractedPalette(Atmosphere.extractPalette(fileUrl))
                    newAtmospherePopup.pickingFile = false
                }
                onCancelled: newAtmospherePopup.pickingFile = false
            }

            AtmosphereColorPicker {
                visible: newAtmospherePopup.pickingColor
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                initialColor: newAtmospherePopup[newAtmospherePopup.editingField]
                onAccepted: function(color) {
                    newAtmospherePopup[newAtmospherePopup.editingField] = color
                    newAtmospherePopup.pickingColor = false
                }
                onCancelled: newAtmospherePopup.pickingColor = false
            }

        }
    }
}
