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
    property int tabHeight:   52

    // 0 = Default, 1 = Custom
    property int currentTab: 0

    // Atmosphere.atmosphereList entries are tagged editable:true when they
    // live in the writable data location - i.e. themes created from this
    // page, as opposed to the read-only system defaults.
    readonly property var defaultAtmospheres: Atmosphere.atmosphereList.filter(
        function(item) { return item.editable !== true }
    )
    readonly property var customAtmospheres: Atmosphere.atmosphereList.filter(
        function(item) { return item.editable === true }
    )

    // Popup button: filled with the primary colour when `primary`, outlined
    // otherwise - same treatment as the interface-mode buttons on HomeScreen.
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

    // Open on the tab that holds the active theme.
    Component.onCompleted: {
        for (var i = 0; i < customAtmospheres.length; i++) {
            if (customAtmospheres[i].path === Atmosphere.path)
                currentTab = 1
        }
    }

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
            // Tabs and theme strip share one container. The active tab is
            // left untinted so it flows straight into the container body;
            // the idle tab gets a darker tint, which is what makes the pair
            // read as attached tabs rather than two loose buttons.
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: tabHeight + 8 + pickerLayout.implicitHeight + cardPadding
                color: secondaryAlphaLightColor
                radius: cardRadius

                Behavior on color {
                    ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                }

                RowLayout {
                    id: tabRow
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                    height: tabHeight
                    spacing: 0

                    Repeater {
                        model: [ qsTr("Default"), qsTr("Custom") ]

                        delegate: CutieButton {
                            id: tabButton
                            readonly property bool active: index === currentTab

                            Layout.fillWidth: true
                            Layout.preferredWidth: 0
                            Layout.fillHeight: true
                            onClicked: currentTab = index

                            // Only the outer top corner is rounded: the
                            // rectangle is oversized and clipped so the
                            // inner corner and the bottom stay square.
                            background: Item {
                                clip: true

                                Rectangle {
                                    x: index === 0 ? 0 : -cardRadius
                                    width: parent.width + cardRadius
                                    height: parent.height + cardRadius
                                    radius: cardRadius
                                    color: tabButton.active
                                           ? Qt.rgba(Atmosphere.secondaryAlphaColor.r,
                                                     Atmosphere.secondaryAlphaColor.g,
                                                     Atmosphere.secondaryAlphaColor.b, 0)
                                           : Atmosphere.secondaryAlphaColor

                                    Behavior on color {
                                        ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                    }
                                }
                            }

                            contentItem: CutieLabel {
                                text: modelData
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 18
                                font.bold: tabButton.active
                                opacity: tabButton.active ? 1.0 : 0.6

                                Behavior on opacity {
                                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: pickerLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: tabRow.bottom
                        topMargin: 8
                        leftMargin: cardPadding
                        rightMargin: cardPadding
                    }
                    spacing: 12

                    // ── One horizontal strip for both tabs. spacing: -20 +
                    // delegate width: 100 matches SettingSheet's layout. ──
                    ListView {
                        id: themeStrip
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        model: currentTab === 0 ? defaultAtmospheres : customAtmospheres
                        orientation: Qt.Horizontal
                        clip: true
                        spacing: -20

                        // "+" tile leads the Custom tab only.
                        header: currentTab === 1 ? addTile : null
                        onModelChanged: positionViewAtBeginning()

                        Component {
                            id: addTile

                            Item {
                                width: 100
                                height: 100

                                Rectangle {
                                    x: 16
                                    y: 6
                                    width: 68
                                    height: 88
                                    radius: 8
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
                        }

                        delegate: Item {
                            width: 100
                            height: 100

                            readonly property bool isSelected: modelData.path === Atmosphere.path

                            Image {
                                id: wallpaper
                                x: 20
                                y: 10
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

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    font.pixelSize: 14
                                    font.family: "Lato"
                                    color: (modelData.variant === "dark") ? "#FFFFFF" : "#000000"
                                }
                            }

                            // Border ring around every tile (same look as the
                            // "+" tile); thicker and fully opaque when selected.
                            Rectangle {
                                id: ring
                                anchors.fill: wallpaper
                                anchors.margins: -4
                                radius: 8
                                color: "transparent"
                                border.color: Atmosphere.textColor
                                border.width: isSelected ? 2 : 1
                                opacity: isSelected ? 1.0 : 0.6

                                Behavior on border.width {
                                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                }
                                Behavior on opacity {
                                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                }
                                Behavior on border.color {
                                    ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                                }
                            }

                            MouseArea {
                                anchors.fill: ring
                                onClicked: Atmosphere.path = modelData.path
                            }
                        }
                    }

                    CutieLabel {
                        visible: currentTab === 1 && customAtmospheres.length === 0
                        Layout.fillWidth: true
                        text: qsTr("Click the + icon to add custom themes")
                        font.pixelSize: 8
                        opacity: 0.9
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
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
        closePolicy: Popup.CloseOnEscape

        property url wallpaperUrl: ""
        property string themeName: ""
        property color primaryColor: "#cccccc"
        property color secondaryColor: "#999999"
        property color accentColor: "#666666"
        property color textColorValue: "#000000"
        property string variantValue: "light"
        property string errorText: ""

        // Colour picker state. The picker replaces the form inside this same
        // popup (rather than opening a second dialog) so the Cutie styling
        // carries through and there is only one modal on screen.
        property bool pickingColor: false
        property string editingField: ""
        property real pickHue: 0
        property real pickSat: 1
        property real pickVal: 1
        readonly property color pickedColor: Qt.hsva(pickHue, pickSat, pickVal, 1)

        function reset() {
            wallpaperUrl = ""
            themeName = ""
            errorText = ""
            pickingColor = false
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
            if (!/^#[0-9a-fA-F]{6}$/.test(hex))
                return
            var c = Qt.color(hex)
            pickHue = Math.max(0, c.hsvHue)
            pickSat = c.hsvSaturation
            pickVal = c.hsvValue
        }

        Overlay.modal: Rectangle {
            color: "#99000000"
        }

        background: Rectangle {
            radius: cardRadius
            color: Atmosphere.primaryColor
            border.color: Atmosphere.textColor
            border.width: 1

            // Tinted layer on top of the solid base, same tint the page cards use
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Atmosphere.secondaryAlphaColor
            }
        }

        contentItem: ColumnLayout {
            spacing: 14

            // ── Form ─────────────────────────────────────────────────
            ColumnLayout {
                visible: !newAtmospherePopup.pickingColor
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
                    onAccepted: newAtmospherePopup.themeName = text
                }

                // Wallpaper picker / preview
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 160
                    radius: 12
                    color: Qt.rgba(0, 0, 0, 0.15)
                    border.color: Atmosphere.textColor
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
                        onClicked: wallpaperFileDialog.open()
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
                                border.color: Atmosphere.textColor
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
                                    onClicked: newAtmospherePopup.beginPick(modelData.key)
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

            // ── Colour picker ────────────────────────────────────────
            ColumnLayout {
                visible: newAtmospherePopup.pickingColor
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
                    color: Qt.hsva(newAtmospherePopup.pickHue, 1, 1, 1)
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
                        x: newAtmospherePopup.pickSat * svBox.width - width / 2
                        y: (1 - newAtmospherePopup.pickVal) * svBox.height - height / 2
                        width: 22
                        height: 22
                        radius: 11
                        color: newAtmospherePopup.pickedColor
                        border.color: "white"
                        border.width: 3
                    }

                    MouseArea {
                        anchors.fill: parent
                        function pick(m) {
                            newAtmospherePopup.pickSat = Math.max(0, Math.min(1, m.x / width))
                            newAtmospherePopup.pickVal = 1 - Math.max(0, Math.min(1, m.y / height))
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
                        x: newAtmospherePopup.pickHue * (hueBar.width - width)
                        anchors.verticalCenter: parent.verticalCenter
                        width: 22
                        height: 34
                        radius: 8
                        color: Qt.hsva(newAtmospherePopup.pickHue, 1, 1, 1)
                        border.color: "white"
                        border.width: 3
                    }

                    MouseArea {
                        anchors.fill: parent
                        function pick(m) {
                            newAtmospherePopup.pickHue = Math.max(0, Math.min(1, m.x / width))
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
                            color: newAtmospherePopup.pickedColor
                        }
                    }

                    CutieTextField {
                        id: hexField
                        Layout.fillWidth: true
                        maximumLength: 7
                        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                        text: newAtmospherePopup.pickedColor.toString().toUpperCase()
                        onEditingFinished: newAtmospherePopup.setPickedFromHex(text)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    PopupButton {
                        text: qsTr("Back")
                        onClicked: newAtmospherePopup.pickingColor = false
                    }

                    PopupButton {
                        primary: true
                        text: qsTr("Done")
                        onClicked: {
                            newAtmospherePopup.setPickedFromHex(hexField.text)
                            newAtmospherePopup[newAtmospherePopup.editingField] = newAtmospherePopup.pickedColor
                            newAtmospherePopup.pickingColor = false
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
}
