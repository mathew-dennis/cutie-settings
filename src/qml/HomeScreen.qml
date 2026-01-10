import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Store

CutiePage {
    id: homeScreenPage

    // --- Variables ---
    property int commonHeight: 60
    property int commonRadius: 6
    // Changed boxColor to transparent
    property color boxColor: "transparent" 
    property color commonBorderColor: "#cccccc"
    property int innerGap: 10 

    Flickable {
        anchors.fill: parent
        contentHeight: mainColumn.height + 40
        clip: true

        Column {
            id: mainColumn
            width: parent.width
            spacing: 20

            CutiePageHeader {
                id: header
                title: qsTr("Home Screen")
                width: parent.width
            }
            
            // Favorites Dock Toggle Section
            Item {
                id: showFavouritsText
                width: parent.width
                height: 40
                CutieLabel {
                    text: qsTr("Favorites Dock")
                    anchors.left: parent.left; anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                }
                CutieToggle {
                    id: visibilityToggle
                    anchors.right: parent.right; anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    checked: true
                }
            }

            // --- THE MASTER GREEN BOX ---
            Rectangle {
                id: masterGreenBox
                width: parent.width * 0.6
                anchors.horizontalCenter: parent.horizontalCenter
                height: commonHeight + (innerGap * 2)
                
                color: "transparent"
                border.color: "green"
                border.width: 2
                radius: 10

                RowLayout {
                    id: innerLayout
                    anchors.fill: parent
                    anchors.margins: innerGap 
                    spacing: innerGap 

                    // BLUE GROUP
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 3
                        height: commonHeight
                        color: "transparent"
                        border.color: "blue"
                        radius: 8

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 4

                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                color: boxColor
                                border.color: commonBorderColor
                                radius: commonRadius
                                Text { text: "notif"; font.pixelSize: 8; anchors.centerIn: parent; visible: parent.width > 20; color: "black" }
                            }
                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                color: boxColor
                                border.color: commonBorderColor
                                radius: commonRadius
                                Rectangle {
                                    width: Math.min(parent.width * 0.7, 40); height: 4; color: "black"; opacity: 0.2; radius: 2 
                                    anchors.bottom: parent.bottom; anchors.bottomMargin: 5; anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                color: boxColor
                                border.color: commonBorderColor
                                radius: commonRadius
                                Text { text: "apps"; font.pixelSize: 8; anchors.centerIn: parent; visible: parent.width > 20; color: "black" }
                            }
                        }
                    }

                    // RED GROUP
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 2
                        height: commonHeight
                        color: "transparent"
                        border.color: "red"
                        radius: 8

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 4

                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                color: boxColor
                                border.color: commonBorderColor
                                radius: commonRadius
                                Text { text: "notif"; font.pixelSize: 8; anchors.centerIn: parent; visible: parent.width > 20; color: "black" }
                            }
                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                color: boxColor
                                border.color: commonBorderColor
                                radius: commonRadius
                                Text { 
                                    text: "apps"; font.pixelSize: 8; color: "black"
                                    anchors.top: parent.top; anchors.topMargin: 5; 
                                    anchors.horizontalCenter: parent.horizontalCenter; 
                                    visible: parent.width > 20 
                                }
                                Rectangle {
                                    width: Math.min(parent.width * 0.7, 40); height: 4; color: "black"; opacity: 0.2; radius: 2 
                                    anchors.bottom: parent.bottom; anchors.bottomMargin: 5; anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                } 
            }
        }
    }

    CutieStore {
        id: favoriteStore
        appName: "cutie-launcher"
        storeName: "favoriteItems"
    }
}