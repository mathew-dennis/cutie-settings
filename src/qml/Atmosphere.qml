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
                }
            }

            Item { width: 1; height: 10 }

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
