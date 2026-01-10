import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Store

CutiePage {
    id: homeScreenPage

    // --- Added Layout Variables ---
    property int commonWidth: 90
    property int commonHeight: 100
    property int commonRadius: 12
    property int commonSpacing: 10
    property color boxColor: "white"
    property color commonBorderColor: "#dddddd" // Softened the black to match UI
    property int groupPadding: 15

    Flickable {
        anchors.fill: parent
        contentHeight: mainColumn.height // Ensures scrolling works if content is tall

        Column {
            id: mainColumn
            width: parent.width
            spacing: 20 // Space between sections

            CutiePageHeader {
                id: header
                title: qsTr("Home Screen")
                width: parent.width
            }
            
            Item {
                id: showFavouritsText
                width: parent.width
                height: visibilityToggle.height
                
                CutieLabel {
                    text: qsTr("Favorites Dock")
                    horizontalAlignment: Text.AlignLeft
                    leftPadding: 20
                    anchors.left: parent.left
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
                        console.log("Settings app: Visibility toggled. Current state:", favoriteStore.data.visibility);
                    }
                }
            }

            // --- START OF NEW GROUPED BOXES SECTION ---
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 30 // Space between the two big group boxes

                // BIG BOX 1: Group of 3
                Rectangle {
                    width: (commonWidth * 3) + (commonSpacing * 2) + (groupPadding * 2)
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
                                text: "notifications"; font.pixelSize: 10
                                anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 10 
                            }
                        }
                        // Box 2
                        Rectangle {
                            width: commonWidth; height: commonHeight; color: boxColor; border.color: commonBorderColor; radius: commonRadius
                            Rectangle {
                                width: parent.width * 0.6; height: 6; color: "black"; opacity: 0.2; radius: 3 
                                anchors.bottom: parent.bottom; anchors.bottomMargin: 12; anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                        // Box 3
                        Rectangle {
                            width: commonWidth; height: commonHeight; color: boxColor; border.color: commonBorderColor; radius: commonRadius
                            Text { text: "no running apps"; font.pixelSize: 10; anchors.centerIn: parent }
                        }
                    }
                }

                // BIG BOX 2: Group of 2
                Rectangle {
                    width: (commonWidth * 2) + commonSpacing + (groupPadding * 2)
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
                                text: "notifications"; font.pixelSize: 10
                                anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 10 
                            }
                        }
                        // Box 5
                        Rectangle {
                            width: commonWidth; height: commonHeight; color: boxColor; border.color: commonBorderColor; radius: commonRadius
                            Text { text: "no running apps"; font.pixelSize: 10; anchors.centerIn: parent }
                            Rectangle {
                                width: parent.width * 0.6; height: 6; color: "black"; opacity: 0.2; radius: 3 
                                anchors.bottom: parent.bottom; anchors.bottomMargin: 12; anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
            // --- END OF NEW SECTION ---
        }
    }

    CutieStore {
        id: favoriteStore
        appName: "cutie-launcher"
        storeName: "favoriteItems"
    }
}