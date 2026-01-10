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
            spacing: 20

            CutiePageHeader {
                id: header
                title: qsTr("Home Screen")
                width: parent.width
            }

            // --- INTERFACE LAYOUT SECTION ---
            Column {
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                CutieLabel {
                    text: qsTr("Interface Layout")
                    font.pixelSize: 18
                    font.bold: true
                }

                CutieLabel {
                    text: qsTr("Note: Choose 'Split' to separate notifications and apps into distinct views, or 'Merged' to combine them into a single streamlined dashboard.")
                    font.pixelSize: 11
                    opacity: 0.6
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }

            // --- THE MASTER GREEN BOX ---
            Rectangle {
                id: masterGreenBox
                width: parent.width * 0.7
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
                    spacing: 20

                    // --- BLUE SECTION (SPLIT) ---
                    ColumnLayout {
                        Layout.fillWidth: true; Layout.preferredWidth: 3; spacing: 12
                        CutieButton {
                            Layout.fillWidth: true; implicitHeight: commonHeight
                            onClicked: {
                                let data = favoriteStore.data;
                                data.InterfaceMode = split;
                                favoriteStore.data = data;
                            }
                            background: Rectangle {
                                color: "transparent"
                                border.color: "blue"
                                border.width: isSplitMode ? 2 : 1
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
                            text: qsTr("split"); Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: 16; font.bold: isSplitMode
                            opacity: isSplitMode ? 1.0 : 0.4
                        }
                    }

                    // --- RED SECTION (MERGED) ---
                    ColumnLayout {
                        Layout.fillWidth: true; Layout.preferredWidth: 2; spacing: 12
                        CutieButton {
                            Layout.fillWidth: true; implicitHeight: commonHeight
                            onClicked: {
                                let data = favoriteStore.data;
                                data.InterfaceMode = merged;
                                favoriteStore.data = data;
                            }
                            background: Rectangle {
                                color: "transparent"
                                border.color: "red"
                                border.width: !isSplitMode ? 2 : 1
                                radius: 8
                            }
                            contentItem: RowLayout {
                                anchors.fill: parent; anchors.margins: 4; spacing: 4
                                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "transparent"; border.color: "#cccccc"; radius: 4 }
                                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "transparent"; border.color: "#cccccc"; radius: 4 }
                            }
                        }
                        CutieLabel {
                            text: qsTr("merged"); Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: 16; font.bold: !isSplitMode
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