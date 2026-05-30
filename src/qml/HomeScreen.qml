import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Store

CutiePage {
    id: homeScreenPage

    readonly property bool split: true
    readonly property bool merged: false
    readonly property color secondaryAlphaLightColor: Qt.rgba (
        Atmosphere.secondaryAlphaColor.r,
        Atmosphere.secondaryAlphaColor.g,
        Atmosphere.secondaryAlphaColor.b,
        0.1
    )

    property int commonHeight: 50
    property int cardRadius: 16
    property int cardPadding: 20

    property real dockScale: homeConfigStore.data && ("dockScale" in homeConfigStore.data)
                             ? homeConfigStore.data.dockScale
                             : 1.0

    property bool isSplitMode: homeConfigStore.data && ("InterfaceMode" in homeConfigStore.data)
                               ? homeConfigStore.data.InterfaceMode === split
                               : merged

    property bool panelMode:   homeConfigStore.data && ("PanelMode" in homeConfigStore.data)
                               ? homeConfigStore.data.PanelMode === split
                               : true

    function setInterfaceMode(mode) {
        let data = homeConfigStore.data
        data.InterfaceMode = mode
        homeConfigStore.data = data
        console.log("settings - InterfaceMode updated. Current state:", mode === split ? "Split" : "Merged")
    }

    Flickable {
        anchors.fill: parent
        contentHeight: mainColumn.height + 40
        clip: true

        Column {
            id: mainColumn
            width: parent.width
            spacing: 0

            // ── Page Header ─────────────────────────────────────────────
            CutiePageHeader {
                id: header
                title: qsTr("Home Screen")
                width: parent.width
            }

            Item { width: 1; height: 24 }

            // ── Interface Layout Card ────────────────────────────────────
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: interfaceLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius

                ColumnLayout {
                    id: interfaceLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 14

                    CutieLabel {
                        text: qsTr("Interface Layout")
                        font.bold: true
                        font.pixelSize: 16
                    }

                    CutieLabel {
                        text: qsTr("Choose how apps are arranged on the home screen.")
                        font.pixelSize: 13
                        opacity: 0.9
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Repeater {
                            model: [
                                { label: qsTr("Split"),  mode: split,  blocks: 3 },
                                { label: qsTr("Merged"), mode: merged, blocks: 2 }
                            ]

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 0
                                spacing: 8

                                CutieButton {
                                    Layout.fillWidth: true
                                    implicitHeight: commonHeight
                                    onClicked: setInterfaceMode(modelData.mode)

                                    background: Rectangle {
                                        color: isSplitMode === modelData.mode
                                               ? Atmosphere.primaryColor
                                               : "transparent"
                                        border.color: isSplitMode === modelData.mode
                                                      ? Atmosphere.primaryColor
                                                      : Atmosphere.secondaryAlphaColor
                                        border.width: 2
                                        radius: 8
                                    }

                                    contentItem: Item {
                                        anchors.fill: parent

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 5

                                            Repeater {
                                                model: modelData.blocks
                                                Rectangle {
                                                    width: 30
                                                    height: commonHeight - 14
                                                    color: "transparent"
                                                    border.color: "white"
                                                    opacity: isSplitMode === modelData.mode ? 1.0 : 0.5
                                                    radius: 4
                                                }
                                            }
                                        }
                                    }
                                }

                                CutieLabel {
                                    text: modelData.label
                                    Layout.alignment: Qt.AlignHCenter
                                    font.bold: isSplitMode === modelData.mode
                                    opacity: isSplitMode === modelData.mode ? 1.0 : 0.7
                                }
                            }
                        }
                    }
                }
            }

            // Note
            Item { width: 1; height: 10 }
            CutieLabel {
                text: qsTr("Note: Split to separate favorite apps and running apps into " +
                           "distinct views, or Merged to combine them into a single streamlined view.")
                font.pixelSize: 11
                opacity: 0.9
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
            }

            Item { width: 1; height: 24 }

            // ── Dock Size Card ───────────────────────────────────────────
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: dockLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius

                ColumnLayout {
                    id: dockLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 14

                    CutieLabel {
                        text: qsTr("Dock Size")
                        font.bold: true
                        font.pixelSize: 16
                    }

                    CutieLabel {
                        text: qsTr("Adjust the width of the dock.")
                        font.pixelSize: 13
                        opacity: 0.7
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        CutieSlider {
                            id: dockSizeSlider
                            Layout.fillWidth: true
                            from: 0.1
                            to: 2.1
                            stepSize: 0.1
                            value: dockScale

                            onMoved: {
                                let d = homeConfigStore.data
                                d.dockScale = value
                                homeConfigStore.data = d
                                console.log("Dock Size slider value:", value)
                            }
                        }

                        CutieLabel {
                            text: qsTr(dockSizeSlider.value.toFixed(1))
                            font.pixelSize: 14
                        }
                    }
                }
            }

            // Note
            Item { width: 1; height: 10 }
            CutieLabel {
                text: qsTr("Note: Changes the dock width. Available in Panel Mode.")
                font.pixelSize: 11
                opacity: 0.9
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
            }

            Item { width: 1; height: 24 }

            // ── Panel Mode Card ──────────────────────────────────────────
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: panelLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius

                RowLayout {
                    id: panelLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 16

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 70
                        spacing: 6

                        CutieLabel {
                            text: qsTr("Panel Mode")
                            font.bold: true
                            font.pixelSize: 16
                        }

                        CutieLabel {
                            text: qsTr("Enable or disable the dock to stretch to full width.")
                            font.pixelSize: 13
                            opacity: 0.7
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }

                    Item {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillWidth: true      
                        Layout.preferredWidth: 30

                        CutieToggle {   
                            id: panelToggle
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 5
                            anchors.rightMargin: 15
                            
                            checked: panelMode

                            onToggled: {
                                let d = homeConfigStore.data
                                d.PanelMode = checked
                                homeConfigStore.data = d
                                console.log("settings - panelMode updated. Current state:",
                                            homeConfigStore.data.PanelMode ? "panel mode" : "dock mode")
                            }
                        }
                    }
                }
            } 

            // Note
            Item { width: 1; height: 10 }
            CutieLabel {
                text: qsTr("Note: When disabled, the dock width adjusts based on the number of apps.")
                font.pixelSize: 11
                opacity: 0.6
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
            }

            Item { width: 1; height: 24 }
        }
    }

    CutieStore {
        id: homeConfigStore
        appName: "cutie-home"
        storeName: "homeConfigs"
    }
}