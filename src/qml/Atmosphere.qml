import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

CutiePage {
    id: atmospherePage

    property int cardRadius:  16
    property int cardPadding: 20

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
                // Match the atmosphere card colour from SettingSheet exactly
                color: Atmosphere.primaryAlphaColor
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

                    // Title — matches SettingSheet's "Atmosphere" heading style
                    Text {
                        text: qsTr("Atmosphere")
                        font.pixelSize: 24
                        font.family: "Lato"
                        font.weight: Font.Black
                        color: Atmosphere.textColor

                        Behavior on color {
                            ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                        }
                    }

                    Text {
                        text: qsTr("Select a theme to change the wallpaper and colour scheme.")
                        font.pixelSize: 13
                        font.family: "Lato"
                        color: Atmosphere.textColor
                        opacity: 0.7
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    // ── 2-column grid of atmosphere thumbnails ────────────
                    // Flow avoids nested-scrollview conflicts with the outer Flickable
                    Flow {
                        id: atmFlow
                        Layout.fillWidth: true
                        spacing: 12

                        Repeater {
                            model: Atmosphere.atmosphereList

                            Item {
                                id: atmTile

                                readonly property bool isSelected: modelData.path === Atmosphere.path

                                // 2-column: subtract the one gap between columns
                                width:  (atmFlow.width - atmFlow.spacing) / 2
                                height: width * 1.35

                                // ── Selection ring (sits outside the tile bounds) ──
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: -3
                                    radius: cardRadius - 2
                                    color: "transparent"
                                    border.color: Atmosphere.textColor
                                    border.width: atmTile.isSelected ? 2 : 0

                                    Behavior on border.width {
                                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                    }
                                    Behavior on border.color {
                                        ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                                    }
                                }

                                // ── Wallpaper preview ──────────────────────
                                Image {
                                    id: wallpaperThumb
                                    anchors.fill: parent
                                    source: "file:/" + modelData.path + "/wallpaper.jpg"
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    clip: true
                                }

                                // Dim unselected tiles slightly
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#000000"
                                    opacity: atmTile.isSelected ? 0.0 : 0.25

                                    Behavior on opacity {
                                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                    }
                                }

                                // ── Atmosphere name ────────────────────────
                                // Colour based on variant, matching SettingSheet exactly
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    font.pixelSize: 14
                                    font.family: "Lato"
                                    font.bold: atmTile.isSelected
                                    color: (modelData.variant === "dark") ? "#FFFFFF" : "#000000"
                                }

                                // ── Checkmark for active atmosphere ────────
                                Text {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 7
                                    text: "✓"
                                    font.pixelSize: 13
                                    font.family: "Lato"
                                    font.bold: true
                                    color: (modelData.variant === "dark") ? "#FFFFFF" : "#000000"
                                    visible: atmTile.isSelected
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Atmosphere.path = modelData.path
                                }
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 10 }

            // Note below card
            Text {
                text: qsTr("Changes apply immediately.")
                font.pixelSize: 11
                font.family: "Lato"
                color: Atmosphere.textColor
                opacity: 0.55
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap

                Behavior on color {
                    ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                }
            }

            Item { width: 1; height: 24 }
        }
    }
}
