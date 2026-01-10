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
    
    // Helper to check current state
    property bool isSplit: "visibility" in favoriteStore.data ? favoriteStore.data["visibility"] : true

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
            
            // Toggle Section (The Reference for size)
            Item {
                id: showFavouritsText
                width: parent.width
                height: 40
                CutieLabel {
                    id: refLabel // Our reference label
                    text: qsTr("Favorites Dock")
                    anchors.left: parent.left; anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    // Default CutieLabel size is usually 16, but we'll match it explicitly
                }
                CutieToggle {
                    id: visibilityToggle
                    anchors.right: parent.right; anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    checked: isSplit
                    onToggled: {
                        let data = favoriteStore.data;
                        data.visibility = visibilityToggle.checked;
                        favoriteStore.data = data;
                    }
                }
            }

            // --- THE MASTER GREEN BOX ---
            Rectangle {
                id: masterGreenBox
                width: parent.width * 0.7 // Widened slightly to fit the larger text better
                anchors.horizontalCenter: parent.horizontalCenter
                height: innerLayout.implicitHeight + (innerGap * 2)
                
                color: "transparent"
                border.color: "#80008000" // 50% transparent green
                border.width: 2
                radius: 10

                RowLayout {
                    id: innerLayout
                    anchors.fill: parent
                    anchors.margins: innerGap
                    spacing: 20 // Increased spacing between the two main options

                    // --- BLUE SECTION (SPLIT) ---
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 3
                        spacing: 12 // Space between button and label

                        CutieButton {
                            id: blueGroupButton
                            Layout.fillWidth: true
                            implicitHeight: commonHeight
                            onClicked: {
                                let data = favoriteStore.data;
                                data.visibility = true;
                                favoriteStore.data = data;
                            }
                            background: Rectangle {
                                color: "transparent"
                                border.color: "blue"
                                border.width: isSplit ? 2 : 1
                                radius: 8
                            }
                            contentItem: RowLayout {
                                anchors.fill: parent; anchors.margins: 4; spacing: 4
                                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "transparent"; border.color: "#cccccc"; radius: 4 }
                                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "transparent"; border.color: "#cccccc"; radius: 4 }
                                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "transparent"; border.color: "#cccccc"; radius: 4 }
                            }
                        }

                        CutieLabel {
                            text: qsTr("split")
                            Layout.alignment: Qt.AlignHCenter
                            // Matched to common CutieLabel size
                            font.pixelSize: 16 
                            font.bold: isSplit
                            opacity: isSplit ? 1.0 : 0.4
                        }
                    }

                    // --- RED SECTION (MERGED) ---
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 2
                        spacing: 12

                        CutieButton {
                            id: redGroupButton
                            Layout.fillWidth: true
                            implicitHeight: commonHeight
                            onClicked: {
                                let data = favoriteStore.data;
                                data.visibility = false;
                                favoriteStore.data = data;
                            }
                            background: Rectangle {
                                color: "transparent"
                                border.color: "red"
                                border.width: !isSplit ? 2 : 1
                                radius: 8
                            }
                            contentItem: RowLayout {
                                anchors.fill: parent; anchors.margins: 4; spacing: 4
                                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "transparent"; border.color: "#cccccc"; radius: 4 }
                                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "transparent"; border.color: "#cccccc"; radius: 4 }
                            }
                        }

                        CutieLabel {
                            text: qsTr("merged")
                            Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: 16
                            font.bold: !isSplit
                            opacity: !isSplit ? 1.0 : 0.4
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