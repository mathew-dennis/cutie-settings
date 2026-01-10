import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Store

CutiePage {
    id: homeScreenPage

    // --- Configuration Constants ---
    readonly property bool split: true
    readonly property bool merged: false

    property int commonHeight: 60
    property int innerGap: 10 
    
    // Helper to read the current mode from the store
    property bool isSplitMode: ("InterfaceMode" in favoriteStore.data) 
                               ? (favoriteStore.data["InterfaceMode"] === split) 
                               : merged

    Flickable {
        anchors.fill: parent
        contentHeight: mainColumn.height + 40
        clip: true

        Column {
            id: mainColumn
            width: parent.width
            spacing: 30 // Increased spacing for a cleaner look

            CutiePageHeader {
                id: header
                title: qsTr("Home Screen")
                width: parent.width
            }

            // --- THE MASTER GREEN BOX ---
            // This now serves as the primary interface for changing modes
            Rectangle {
                id: masterGreenBox
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                
                // Height adapts to the buttons and labels inside
                height: innerLayout.implicitHeight + (innerGap * 2)
                
                color: "transparent"
                border.color: "#80008000" // 50% transparent green
                border.width: 2
                radius: 10

                RowLayout {
                    id: innerLayout
                    anchors.fill: parent
                    anchors.margins: innerGap
                    spacing: 20

                    // --- BLUE SECTION (SPLIT) ---
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 3
                        spacing: 12

                        CutieButton {
                            id: blueGroupButton
                            Layout.fillWidth: true
                            implicitHeight: commonHeight
                            
                            onClicked: {
                                let data = favoriteStore.data;
                                data.InterfaceMode = split;
                                favoriteStore.data = data;
                                console.log("home - InterfaceMode set to split");
                            }

                            background: Rectangle {
                                color: "transparent"
                                border.color: "blue"
                                // Thicker border when selected
                                border.width: isSplitMode ? 2 : 1
                                radius: 8
                            }

                            contentItem: RowLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 4
                                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "transparent"; border.color: "#cccccc"; radius: 4 }
                                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "transparent"; border.color: "#cccccc"; radius: 4 }
                                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "transparent"; border.color: "#cccccc"; radius: 4 }
                            }
                        }

                        CutieLabel {
                            text: qsTr("split")
                            Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: 16 
                            font.bold: isSplitMode
                            // Fades text if not selected
                            opacity: isSplitMode ? 1.0 : 0.4
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
                                data.InterfaceMode = merged;
                                favoriteStore.data = data;
                                console.log("home - InterfaceMode set to merged");
                            }

                            background: Rectangle {
                                color: "transparent"
                                border.color: "red"
                                // Thicker border when selected
                                border.width: !isSplitMode ? 2 : 1
                                radius: 8
                            }

                            contentItem: RowLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 4
                                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "transparent"; border.color: "#cccccc"; radius: 4 }
                                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "transparent"; border.color: "#cccccc"; radius: 4 }
                            }
                        }

                        CutieLabel {
                            text: qsTr("merged")
                            Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: 16
                            font.bold: !isSplitMode
                            opacity: !isSplitMode ? 1.0 : 0.4
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