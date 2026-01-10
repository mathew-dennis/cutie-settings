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
    property color boxColor: "white"
    property color commonBorderColor: "#cccccc"
    property int groupPadding: 6

    Flickable {
        anchors.fill: parent
        contentHeight: mainColumn.height + 40
        clip: true

        Column {
            id: mainColumn
            width: parent.width
            spacing: 15

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
                width: parent.width
                // Height calculates based on the content inside + padding
                height: innerLayout.height + 40 
                color: "transparent"
                border.color: "green"
                border.width: 2
                radius: 10

                // Inner Container to handle the 20% side padding
                Item {
                    id: paddingContainer
                    // 20% padding on each side = 60% total width
                    width: parent.width * 0.6 
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter

                    RowLayout {
                        id: innerLayout
                        anchors.fill: parent
                        spacing: 10

                        // BIG BOX 1 (Group of 3 - Blue)
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 3
                            height: commonHeight + (groupPadding * 2)
                            color: "transparent"
                            border.color: "blue"
                            radius: 8

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: groupPadding
                                spacing: 4

                                Rectangle {
                                    Layout.fillWidth: true; Layout.fillHeight: true
                                    color: boxColor; border.color: commonBorderColor; radius: commonRadius
                                    Text { text: "notif"; font.pixelSize: 8; anchors.centerIn: parent; visible: parent.width > 25 }
                                }
                                Rectangle {
                                    Layout.fillWidth: true; Layout.fillHeight: true
                                    color: boxColor; border.color: commonBorderColor; radius: commonRadius
                                    Rectangle {
                                        width: parent.width * 0.7; height: 4; color: "black"; opacity: 0.2; radius: 2 
                                        anchors.bottom: parent.bottom; anchors.bottomMargin: 5; anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                                Rectangle {
                                    Layout.fillWidth: true; Layout.fillHeight: true
                                    color: boxColor; border.color: commonBorderColor; radius: commonRadius
                                    Text { text: "apps"; font.pixelSize: 8; anchors.centerIn: parent; visible: parent.width > 25 }
                                }
                            }
                        }

                        // BIG BOX 2 (Group of 2 - Red)
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 2
                            height: commonHeight + (groupPadding * 2)
                            color: "transparent"
                            border.color: "red"
                            radius: 8

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: groupPadding
                                spacing: 4

                                Rectangle {
                                    Layout.fillWidth: true; Layout.fillHeight: true
                                    color: boxColor; border.color: commonBorderColor; radius: commonRadius
                                    Text { text: "notif"; font.pixelSize: 8; anchors.centerIn: parent; visible: parent.width > 25 }
                                }
                                Rectangle {
                                    Layout.fillWidth: true; Layout.fillHeight: true
                                    color: boxColor; border.color: commonBorderColor; radius: commonRadius
                                    Text { text: "apps"; font.pixelSize: 8; anchors.top: parent.top; anchors.topMargin: 5; anchors.horizontalCenter: parent.horizontalCenter; visible: parent.width > 25 }
                                    Rectangle {
                                        width: parent.width * 0.7; height: 4; color: "black"; opacity: 0.2; radius: 2 
                                        anchors.bottom: parent.bottom; anchors.bottomMargin: 5; anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        }
                    } // End of RowLayout
                } // End of Padding Container
            } // End of Green Box
        }
    }

    CutieStore {
        id: favoriteStore
        appName: "cutie-launcher"
        storeName: "favoriteItems"
    }
}