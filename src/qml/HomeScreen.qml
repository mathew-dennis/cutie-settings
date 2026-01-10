import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Store

CutiePage {
    id: homeScreenPage

    // --- Dynamic Variables (Responsive Scaling) ---
    // This calculates width based on the window. 0.15 means each small box takes 15% of the screen.
    property real boxWidthMultiplier: 0.16 
    property int commonWidth: Math.max(60, parent.width * boxWidthMultiplier) 
    property int commonHeight: 80
    property int commonRadius: 8
    property int commonSpacing: 4
    property color boxColor: "white"
    property color commonBorderColor: "#cccccc"
    property int groupPadding: 8

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
                height: visibilityToggle.height
                
                CutieLabel {
                    text: qsTr("Favorites Dock")
                    horizontalAlignment: Text.AlignLeft
                    leftPadding: 20
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }

                CutieToggle {
                    id: visibilityToggle
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 15
                    checked: "visibility" in favoriteStore.data ? favoriteStore.data["visibility"] : true
                    onToggled: {
                        let data = favoriteStore.data;
                        data.visibility = visibilityToggle.checked;
                        favoriteStore.data = data;
                    }
                }
            }

            // --- RESPONSIVE ROW (FORCED SINGLE LINE) ---
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 15 // Gap between the Blue and Red groups

                // BIG BOX 1: Group of 3
                Rectangle {
                    id: bigBox1
                    width: (commonWidth * 3) + (commonSpacing * 2) + (groupPadding * 2)
                    height: commonHeight + (groupPadding * 2)
                    color: "transparent"
                    border.color: "blue"
                    border.width: 1
                    radius: 12

                    Row {
                        anchors.centerIn: parent
                        spacing: commonSpacing
                        
                        // Box 1
                        Rectangle {
                            width: commonWidth; height: commonHeight; color: boxColor; border.color: commonBorderColor; radius: commonRadius
                            Text {
                                text: "notif"; font.pixelSize: 8; color: "black"
                                anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 5 
                            }
                        }
                        // Box 2
                        Rectangle {
                            width: commonWidth; height: commonHeight; color: boxColor; border.color: commonBorderColor; radius: commonRadius
                            Rectangle {
                                width: parent.width * 0.7; height: 4; color: "black"; opacity: 0.2; radius: 2 
                                anchors.bottom: parent.bottom; anchors.bottomMargin: 8; anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                        // Box 3
                        Rectangle {
                            width: commonWidth; height: commonHeight; color: boxColor; border.color: commonBorderColor; radius: commonRadius
                            Text { 
                                text: "apps"; font.pixelSize: 8; color: "black"
                                anchors.centerIn: parent; horizontalAlignment: Text.AlignHCenter; width: parent.width - 4; wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                // BIG BOX 2: Group of 2
                Rectangle {
                    id: bigBox2
                    width: (commonWidth * 2) + commonSpacing + (groupPadding * 2)
                    height: commonHeight + (groupPadding * 2)
                    color: "transparent"
                    border.color: "red"
                    border.width: 1
                    radius: 12

                    Row {
                        anchors.centerIn: parent
                        spacing: commonSpacing

                        // Box 4
                        Rectangle {
                            width: commonWidth; height: commonHeight; color: boxColor; border.color: commonBorderColor; radius: commonRadius
                            Text {
                                text: "notif"; font.pixelSize: 8; color: "black"
                                anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 5 
                            }
                        }
                        // Box 5
                        Rectangle {
                            width: commonWidth; height: commonHeight; color: boxColor; border.color: commonBorderColor; radius: commonRadius
                            Text { 
                                text: "apps"; font.pixelSize: 8; color: "black"
                                anchors.centerIn: parent; horizontalAlignment: Text.AlignHCenter; width: parent.width - 4; wrapMode: Text.WordWrap
                            }
                            Rectangle {
                                width: parent.width * 0.7; height: 4; color: "black"; opacity: 0.2; radius: 2 
                                anchors.bottom: parent.bottom; anchors.bottomMargin: 8; anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            } // End of Row
        }
    }

    CutieStore {
        id: favoriteStore
        appName: "cutie-launcher"
        storeName: "favoriteItems"
    }
}