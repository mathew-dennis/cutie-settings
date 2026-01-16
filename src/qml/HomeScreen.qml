import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Store

CutiePage {
    id: homeScreenPage

    readonly property bool split: true
    readonly property bool merged: false

    property int commonHeight: 60
    property int innerGap: 10

    property real dockScale: ("dockScale" in favoriteStore.data) 
                             ? favoriteStore.data.dockScale : 1.0

    property bool isSplitMode: ("InterfaceMode" in favoriteStore.data)
                               ? favoriteStore.data.InterfaceMode === split
                               : merged

    function setInterfaceMode(mode) {
        let data = favoriteStore.data
        data.InterfaceMode = mode
        favoriteStore.data = data
    }

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

            CutieLabel {
                text: qsTr("Interface Layout")
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                height: layoutRow.implicitHeight + innerGap * 2
                color: "transparent"
                border.color: Atmosphere.primaryAlphaColor
                border.width: 2
                radius: 10

                RowLayout {
                    id: layoutRow
                    anchors.fill: parent
                    anchors.margins: innerGap
                    spacing: 20

                    Repeater {
                        model: [
                            { label: qsTr("Split"),  mode: split,  blocks: 3, color: Atmosphere.secondaryAlphaColor },
                            { label: qsTr("Merged"), mode: merged, blocks: 2, color: Atmosphere.secondaryAlphaColor }
                        ]

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            CutieButton {
                                Layout.fillWidth: true
                                implicitHeight: commonHeight
                                onClicked: setInterfaceMode(modelData.mode)

                                background: Rectangle {
                                    color: "transparent"
                                    border.color: modelData.color
                                    border.width: isSplitMode === modelData.mode ? 2 : 1
                                    radius: 8
                                }

                                contentItem: RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    spacing: 4

                                    Repeater {
                                        model: modelData.blocks
                                        Rectangle {
                                            Layout.preferredWidth: 40
                                            Layout.fillHeight: true
                                            color: "transparent"
                                            border.color: "#cccccc"
                                            radius: 4
                                        }
                                    }
                                }
                            }

                            CutieLabel {
                                text: modelData.label
                                Layout.alignment: Qt.AlignHCenter
                                font.bold: isSplitMode === modelData.mode
                                opacity: isSplitMode === modelData.mode ? 1.0 : 0.4
                            }
                        }
                    }
                }
            }

            CutieLabel {
                text: qsTr(
                    "Note: Choose 'Split' to separate favorite apps and running apps into distinct views, or 'Merged' to combine them into a single streamlined view."
                )
                font.pixelSize: 11
                opacity: 0.6
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
            }

            CutieLabel {
                text: qsTr("Dock Size")
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: 10
                bottomPadding: 4
            }

            Column {
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4

                CutieSlider {
                    id: dockSizeSlider
                    width: parent.width
                    from: 0.1
                    to: 2.1
                    stepSize: 0.1
                    value: dockScale

                    onMoved: {
                        dockScale = value

                        let d = favoriteStore.data
                        d.dockScale = value
                        favoriteStore.data = d
                        console.log("Dock Size slider value:", value)
                    }
                }

                CutieLabel {
                    text: dockScale.toFixed(1)
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Rectangle {
                width: parent.width * 0.7
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"

                CutieLabel {
                    id: panelLabel
                    text: qsTr("Panel Mode")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                }

                CutieToggle {
                    id: panelModeToggle
                    width: 60       // explicit width
                    height: 30      // explicit height
                    implicitHeight: 30
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 15

                    Component.onCompleted: {
                    checked = ("PanelMode" in favoriteStore.data) ? favoriteStore.data.PanelMode : true
                    }
                    onToggled: {
                        let d = favoriteStore.data
                        d.PanelMode = !d.PanelMode
                        favoriteStore.data = d
                        console.log("settings - panelMode updated. Current state:", favoriteStore.data.PanelMode ? "panel mode" : "e mode")
                    }
                }
            }


            CutieLabel {
                text: qsTr(
                    "Note: Enable Panel Mode to stretch the dock to full width. " +
                    "When disabled, the dock width adjusts based on the number of apps."
                )
                font.pixelSize: 11
                opacity: 0.6
                width: parent.width * 0.7
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
            }

        }
    }

    CutieStore {
        id: favoriteStore
        appName: "cutie-launcher"
        storeName: "favoriteItems"
    }
}
