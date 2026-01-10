import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Store

CutiePage {
    id: homeScreenPage

    // --- Variables ---
    property int commonHeight: 60
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

                    // --- BLUE CUTIE BUTTON (Container for 3 boxes) ---
                    CutieButton {
                        id: blueGroupButton
                        Layout.fillWidth: true
                        Layout.preferredWidth: 3
                        implicitHeight: commonHeight
                        
                        // Customizing background to show Blue Border & Transparency
                        background: Rectangle {
                            color: "transparent"
                            border.color: "blue"
                            border.width: 1
                            radius: 8
                        }

                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 4

                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                color: "transparent"; border.color: "#cccccc"; radius: 4
                                Text { text: "notif"; font.pixelSize: 8; anchors.centerIn: parent; color: "black" }
                            }
                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                color: "transparent"; border.color: "#cccccc"; radius: 4
                                Rectangle {
                                    width: parent.width * 0.7; height: 4; color: "black"; opacity: 0.2; radius: 2 
                                    anchors.bottom: parent.bottom; anchors.bottomMargin: 5; anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                color: "transparent"; border.color: "#cccccc"; radius: 4
                                Text { text: "apps"; font.pixelSize: 8; anchors.centerIn: parent; color: "black" }
                            }
                        }
                    }

                    // --- RED CUTIE BUTTON (Container for 2 boxes) ---
                    CutieButton {
                        id: redGroupButton
                        Layout.fillWidth: true
                        Layout.preferredWidth: 2
                        implicitHeight: commonHeight
                        
                        // Customizing background to show Red Border & Transparency
                        background: Rectangle {
                            color: "transparent"
                            border.color: "red"
                            border.width: 1
                            radius: 8
                        }

                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 4

                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                color: "transparent"; border.color: "#cccccc"; radius: 4
                                Text { text: "notif"; font.pixelSize: 8; anchors.centerIn: parent; color: "black" }
                            }
                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                color: "transparent"; border.color: "#cccccc"; radius: 4
                                Text { 
                                    text: "apps"; font.pixelSize: 8; color: "black"
                                    anchors.top: parent.top; anchors.topMargin: 5; anchors.horizontalCenter: parent.horizontalCenter 
                                }
                                Rectangle {
                                    width: parent.width * 0.7; height: 4; color: "black"; opacity: 0.2; radius: 2 
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