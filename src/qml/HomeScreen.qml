import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Store

CutiePage {
    id: homeScreenPage

    // --- Variables (Adjust these to change the look) ---
    property int commonWidth: 90
    property int commonHeight: 100
    property int commonRadius: 12
    property int commonSpacing: 8
    property color boxColor: "white"
    property color commonBorderColor: "#cccccc"
    property int groupPadding: 12

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

            // --- RESPONSIVE GROUPED BOXES SECTION ---
            // Flow acts like a Row that wraps to a new line if it runs out of width
            Flow {
                width: parent.width
                padding: 15
                spacing: 20
                flow: Flow.LeftToRight

                // BIG BOX 1: Group of 3
                Rectangle {
                    id: bigBox1
                    width: Math.min(parent.width - 30, (commonWidth * 3) + (commonSpacing * 2) + (groupPadding * 2))
                    height: commonHeight + (groupPadding * 2)
                    color: "transparent"
                    border.color: "blue"
                    border.width: 1
                    radius: 15

                    Row {
                        anchors.centerIn: parent
                        spacing: commonSpacing
                        
                        // Box 1
                        Rectangle {
                            width: commonWidth; height: commonHeight; color: boxColor; border.color: commonBorderColor; radius: commonRadius
                            Text {
                                text: "notifications"; font.pixelSize: 9; color: "black"
                                anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 8 
                            }
                        }
                        // Box 2
                        Rectangle {
                            width: commonWidth; height: commonHeight; color: boxColor; border.color: commonBorderColor; radius: commonRadius
                            Rectangle {
                                width: parent.width * 0.7; height: 5; color: "black"; opacity: 0.2; radius: 3 
                                anchors.bottom: parent.bottom; anchors.bottomMargin: 12; anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                        // Box 3
                        Rectangle {
                            width: commonWidth; height: commonHeight; color: boxColor; border.color: commonBorderColor; radius: commonRadius
                            Text { 
                                text: "no running apps"; font.pixelSize: 9; color: "black"
                                anchors.centerIn: parent; horizontalAlignment: Text.AlignHCenter; width: parent.width - 10; wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                // BIG BOX 2: Group of 2
                Rectangle {
                    id: bigBox2
                    width: Math.min(parent.width - 30, (commonWidth * 2) + commonSpacing + (groupPadding * 2))
                    height: commonHeight + (groupPadding * 2)
                    color: "transparent"
                    border.color: "red"
                    border.width: 1
                    radius: 15

                    Row {
                        anchors.centerIn: parent
                        spacing: commonSpacing

                        // Box 4
                        Rectangle {
                            width: commonWidth; height: commonHeight; color: boxColor; border.color: commonBorderColor; radius: commonRadius
                            Text {
                                text: "notifications"; font.pixelSize: 9; color: "black"
                                anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 8 
                            }
                        }
                        // Box 5
                        Rectangle {
                            width: commonWidth; height: commonHeight; color: boxColor; border.color: commonBorderColor; radius: commonRadius
                            Text { 
                                text: "no running apps"; font.pixelSize: 9; color: "black"
                                anchors.centerIn: parent; horizontalAlignment: Text.AlignHCenter; width: parent.width - 10; wrapMode: Text.WordWrap
                            }
                            Rectangle {
                                width: parent.width * 0.7; height: 5; color: "black"; opacity: 0.2; radius: 3 
                                anchors.bottom: parent.bottom; anchors.bottomMargin: 12; anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            } // End of Flow
        }
    }

    CutieStore {
        id: favoriteStore
        appName: "cutie-launcher"
        storeName: "favoriteItems"
    }
}