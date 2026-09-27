import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

CutiePage {
    id: atmospherePage

    readonly property color secondaryAlphaLightColor: Qt.rgba(
        Atmosphere.secondaryAlphaColor.r,
        Atmosphere.secondaryAlphaColor.g,
        Atmosphere.secondaryAlphaColor.b,
        0.1
    )
    property int cardRadius:  16
    property int cardPadding: 20

    // Atmosphere.atmosphereList entries are tagged editable:true when they
    // live in the writable data location - i.e. themes created from this
    // page, as opposed to the read-only system defaults.
    readonly property var customAtmospheres: Atmosphere.atmosphereList.filter(
        function(item) { return item.editable === true }
    )

    Flickable {
        id: pageFlickable
        anchors.fill: parent
        contentHeight: mainColumn.height + 40
        clip: true

        Column {
            id: mainColumn
            width: parent.width
            spacing: 0

            // ── Page Header ──────────────────────────────────────────────
            CutiePageHeader {
                title: qsTr("Atmosphere")
                width: parent.width
            }

            Item { width: 1; height: 24 }

            // ── Atmosphere Picker Card ───────────────────────────────────
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: pickerLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius

                Behavior on color {
                    ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                }

                ColumnLayout {
                    id: pickerLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 16

                    Text {
                        text: qsTr("Default Atmosphere")
                        font.pixelSize: 24
                        font.family: "Lato"
                        font.weight: Font.Black
                        color: Atmosphere.textColor

                        Behavior on color {
                            ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                        }
                    }

                    // ── Horizontal scroll strip — matches SettingSheet exactly ──
                    // spacing: -20 + delegate width: 100 gives the same overlapping
                    // fan effect as the original panel.
                    ListView {
                        Layout.fillWidth: true
                        height: 100
                        model: Atmosphere.atmosphereList
                        orientation: Qt.Horizontal
                        clip: true
                        spacing: -20

                        delegate: Item {
                            width: 100
                            height: 100

                            readonly property bool isSelected: modelData.path === Atmosphere.path

                            Image {
                                x: 20
                                width: 60
                                height: 80
                                source: "file:/" + modelData.path + "/wallpaper.jpg"
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true

                                // Dim unselected tiles
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#000000"
                                    opacity: isSelected ? 0.0 : 0.3

                                    Behavior on opacity {
                                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                    }
                                }

                                // Selection ring
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: -2
                                    color: "transparent"
                                    border.color: Atmosphere.textColor
                                    border.width: isSelected ? 2 : 0

                                    Behavior on border.width {
                                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                    }
                                    Behavior on border.color {
                                        ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    font.pixelSize: 14
                                    font.bold: false
                                    font.family: "Lato"
                                    color: (modelData.variant === "dark") ? "#FFFFFF" : "#000000"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Atmosphere.path = modelData.path
                                }
                            }
                        }
                    }

                    Text {
                        text: qsTr("Custom Atmosphere")
                        font.pixelSize: 24
                        font.family: "Lato"
                        font.weight: Font.Black
                        color: Atmosphere.textColor

                        Behavior on color {
                            ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                        }
                    }

                    // ── Custom atmosphere strip — "+" tile always first (via
                    // ListView.header), then any themes created from this
                    // page. Same tile geometry/behaviour as the default strip
                    // above so the two rows read as one family. ──
                    ListView {
                        Layout.fillWidth: true
                        height: 100
                        model: customAtmospheres
                        orientation: Qt.Horizontal
                        clip: true
                        spacing: -20

                        header: Item {
                            width: 100
                            height: 100

                            Rectangle {
                                x: 20
                                width: 60
                                height: 80
                                radius: 6
                                color: "transparent"
                                border.color: Atmosphere.textColor
                                border.width: 1
                                opacity: 0.6

                                Text {
                                    anchors.centerIn: parent
                                    text: "+"
                                    font.pixelSize: 32
                                    font.family: "Lato"
                                    color: Atmosphere.textColor
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        newAtmospherePopup.reset()
                                        newAtmospherePopup.open()
                                    }
                                }
                            }
                        }

                        delegate: Item {
                            width: 100
                            height: 100

                            readonly property bool isSelected: modelData.path === Atmosphere.path

                            Image {
                                x: 20
                                width: 60
                                height: 80
                                source: "file:/" + modelData.path + "/wallpaper.jpg"
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true

                                Rectangle {
                                    anchors.fill: parent
                                    color: "#000000"
                                    opacity: isSelected ? 0.0 : 0.3

                                    Behavior on opacity {
                                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                    }
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: -2
                                    color: "transparent"
                                    border.color: Atmosphere.textColor
                                    border.width: isSelected ? 2 : 0

                                    Behavior on border.width {
                                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                    }
                                    Behavior on border.color {
                                        ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    font.pixelSize: 14
                                    font.family: "Lato"
                                    color: (modelData.variant === "dark") ? "#FFFFFF" : "#000000"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Atmosphere.path = modelData.path
                                }
                            }
                        }
                    }

                    Text {
                        visible: customAtmospheres.length === 0
                        text: qsTr("Click the + icon to add custom themes")
                        font.pixelSize: 20
                        font.family: "Lato"
                        color: Atmosphere.textColor
                        opacity: 0.9
                        anchors.horizontalCenter: parent.horizontalCenter
                        wrapMode: Text.WordWrap

                        Behavior on color {
                            ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                        }
                    }
                }
            }
        }
    }

    // ── New Atmosphere popup ────────────────────────────────────────────
    Popup {
        id: newAtmospherePopup
        anchors.centerIn: parent
        width: Math.min(atmospherePage.width - 40, 420)
        modal: true
        focus: true
        padding: cardPadding

        property url wallpaperUrl: ""
        property string themeName: ""
        property color primaryColor: "#cccccc"
        property color secondaryColor: "#999999"
        property color accentColor: "#666666"
        property color textColorValue: "#000000"
        property string variantValue: "light"
        property string errorText: ""

        function reset() {
            wallpaperUrl = ""
            themeName = ""
            errorText = ""
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

        contentItem: ColumnLayout {
            spacing: 14

            Text {
                text: qsTr("New Atmosphere")
                font.pixelSize: 20
                font.family: "Lato"
                font.weight: Font.Black
                color: Atmosphere.textColor
            }

            TextField {
                Layout.fillWidth: true
                placeholderText: qsTr("Theme name")
                text: newAtmospherePopup.themeName
                onTextChanged: newAtmospherePopup.themeName = text
            }

            // Wallpaper picker / preview
            Rectangle {
                Layout.fillWidth: true
                height: 180
                radius: cardRadius
                color: "#22000000"
                border.color: Atmosphere.textColor
                border.width: newAtmospherePopup.wallpaperUrl == "" ? 1 : 0
                clip: true

                Image {
                    anchors.fill: parent
                    source: newAtmospherePopup.wallpaperUrl
                    fillMode: Image.PreserveAspectCrop
                    visible: newAtmospherePopup.wallpaperUrl != ""
                    asynchronous: true
                }

                Text {
                    anchors.centerIn: parent
                    visible: newAtmospherePopup.wallpaperUrl == ""
                    text: qsTr("Tap to select wallpaper")
                    font.family: "Lato"
                    color: Atmosphere.textColor
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: wallpaperFileDialog.open()
                }
            }

            // Colour swatches - populated from extraction, each tappable to
            // open the shared ColorDialog and override the value.
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: newAtmospherePopup.wallpaperUrl != ""

                Repeater {
                    model: [
                        { label: qsTr("Primary"), key: "primaryColor" },
                        { label: qsTr("Secondary"), key: "secondaryColor" },
                        { label: qsTr("Accent"), key: "accentColor" },
                        { label: qsTr("Text"), key: "textColorValue" }
                    ]

                    delegate: ColumnLayout {
                        spacing: 4

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 40
                            height: 40
                            radius: 20
                            color: newAtmospherePopup[modelData.key]
                            border.color: Atmosphere.textColor
                            border.width: 1

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    colorDialog.editingField = modelData.key
                                    colorDialog.selectedColor = newAtmospherePopup[modelData.key]
                                    colorDialog.open()
                                }
                            }
                        }

                        Text {
                            text: modelData.label
                            font.pixelSize: 12
                            font.family: "Lato"
                            color: Atmosphere.textColor
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }

            Text {
                visible: newAtmospherePopup.errorText !== ""
                text: newAtmospherePopup.errorText
                color: "#ff5555"
                font.family: "Lato"
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    text: qsTr("Cancel")
                    Layout.fillWidth: true
                    onClicked: newAtmospherePopup.close()
                }

                Button {
                    text: qsTr("Save")
                    Layout.fillWidth: true
                    enabled: newAtmospherePopup.wallpaperUrl != "" && newAtmospherePopup.themeName.length > 0
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
                        var ok = Atmosphere.saveAtmosphere(
                            newAtmospherePopup.themeName,
                            newAtmospherePopup.wallpaperUrl,
                            colors
                        )
                        if (ok) {
                            newAtmospherePopup.close()
                        } else {
                            newAtmospherePopup.errorText = qsTr("Couldn't save - try a different name.")
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
            newAtmospherePopup.wallpaperUrl = selectedFile
            newAtmospherePopup.applyExtractedPalette(Atmosphere.extractPalette(selectedFile))
        }
    }

    ColorDialog {
        id: colorDialog
        property string editingField: ""
        onAccepted: {
            newAtmospherePopup[editingField] = selectedColor
        }
    }
}