import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

CutiePage {
    id: atmospherePage

    readonly property color secondaryAlphaLightColor: Qt.rgba(
        Atmosphere.secondaryAlphaColor.r,
        Atmosphere.secondaryAlphaColor.g,
        Atmosphere.secondaryAlphaColor.b,
        0.1
    )
    property int cardRadius:  16
    property int cardPadding: 20
    property int tabHeight:   52
    property var newAtmosphereComponent: Qt.createComponent("NewAtmosphere.qml")

    // 0 = Default, 1 = Custom
    property int currentTab: 0

    // Atmosphere.atmosphereList entries are tagged editable:true when they
    // live in the writable data location - i.e. themes created from this
    // page, as opposed to the read-only system defaults.
    readonly property var defaultAtmospheres: Atmosphere.atmosphereList.filter(
        function(item) { return item.editable !== true }
    )
    readonly property var customAtmospheres: Atmosphere.atmosphereList.filter(
        function(item) { return item.editable === true }
    )

    // Open on the tab that holds the active theme.
    Component.onCompleted: {
        for (var i = 0; i < customAtmospheres.length; i++) {
            if (customAtmospheres[i].path === Atmosphere.path)
                currentTab = 1
        }
    }

    Flickable {
        id: pageFlickable
        anchors.fill: parent
        contentHeight: mainColumn.height + 40
        clip: true

        Column {
            id: mainColumn
            width: parent.width
            spacing: 0

            // ── Page Header ──────────────────────────────────────────────
            CutiePageHeader {
                title: qsTr("Atmosphere")
                width: parent.width
            }

            Item { width: 1; height: 24 }

            // ── Atmosphere Picker Card ───────────────────────────────────
            // Tabs and theme strip share one container. The active tab is
            // left untinted so it flows straight into the container body;
            // the idle tab gets a darker tint, which is what makes the pair
            // read as attached tabs rather than two loose buttons.
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: tabHeight + 8 + pickerLayout.implicitHeight + cardPadding
                color: secondaryAlphaLightColor
                radius: cardRadius

                Behavior on color {
                    ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                }

                RowLayout {
                    id: tabRow
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                    height: tabHeight
                    spacing: 0

                    Repeater {
                        model: [ qsTr("Default"), qsTr("Custom") ]

                        delegate: CutieButton {
                            id: tabButton
                            readonly property bool active: index === currentTab

                            Layout.fillWidth: true
                            Layout.preferredWidth: 0
                            Layout.fillHeight: true
                            onClicked: currentTab = index

                            // Only the outer top corner is rounded: the
                            // rectangle is oversized and clipped so the
                            // inner corner and the bottom stay square.
                            background: Item {
                                clip: true

                                Rectangle {
                                    x: index === 0 ? 0 : -cardRadius
                                    width: parent.width + cardRadius
                                    height: parent.height + cardRadius
                                    radius: cardRadius
                                    color: tabButton.active
                                           ? Qt.rgba(Atmosphere.secondaryAlphaColor.r,
                                                     Atmosphere.secondaryAlphaColor.g,
                                                     Atmosphere.secondaryAlphaColor.b, 0)
                                           : Atmosphere.secondaryAlphaColor

                                    Behavior on color {
                                        ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                    }
                                }
                            }

                            contentItem: CutieLabel {
                                text: modelData
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 18
                                font.bold: tabButton.active
                                opacity: tabButton.active ? 1.0 : 0.6

                                Behavior on opacity {
                                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: pickerLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: tabRow.bottom
                        topMargin: 8
                        leftMargin: cardPadding
                        rightMargin: cardPadding
                    }
                    spacing: 12

                    // ── One horizontal strip for both tabs. spacing: -20 +
                    // delegate width: 100 matches SettingSheet's layout. ──
                    ListView {
                        id: themeStrip
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        model: currentTab === 0 ? defaultAtmospheres : customAtmospheres
                        orientation: Qt.Horizontal
                        clip: true
                        spacing: -20

                        // "+" tile leads the Custom tab only.
                        header: currentTab === 1 ? addTile : null
                        onModelChanged: positionViewAtBeginning()

                        Component {
                            id: addTile

                            Item {
                                width: 100
                                height: 100

                                Rectangle {
                                    x: 16
                                    y: 6
                                    width: 68
                                    height: 88
                                    radius: 8
                                    color: "transparent"
                                    border.color: Atmosphere.textColor
                                    border.width: 1
                                    opacity: 0.6

                                    Text {
                                        anchors.centerIn: parent
                                        text: "+"
                                        font.pixelSize: 32
                                        font.family: "Lato"
                                        color: Atmosphere.textColor
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (newAtmosphereComponent.status === Component.Ready)
                                                mainWindow.pageStack.push(newAtmosphereComponent)
                                        }
                                    }
                                }
                            }
                        }

                        delegate: Item {
                            width: 100
                            height: 100

                            readonly property bool isSelected: modelData.path === Atmosphere.path

                            Image {
                                id: wallpaper
                                x: 20
                                y: 10
                                width: 60
                                height: 80
                                source: "file:/" + modelData.path + "/wallpaper.jpg"
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true

                                // Dim unselected tiles
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#000000"
                                    opacity: isSelected ? 0.0 : 0.3

                                    Behavior on opacity {
                                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    font.pixelSize: 14
                                    font.family: "Lato"
                                    color: (modelData.variant === "dark") ? "#FFFFFF" : "#000000"
                                }
                            }

                            // Border ring around every tile (same look as the
                            // "+" tile); thicker and fully opaque when selected.
                            Rectangle {
                                id: ring
                                anchors.fill: wallpaper
                                anchors.margins: -4
                                radius: 8
                                color: "transparent"
                                border.color: Atmosphere.textColor
                                border.width: isSelected ? 2 : 1
                                opacity: isSelected ? 1.0 : 0.6

                                Behavior on border.width {
                                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                }
                                Behavior on opacity {
                                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                }
                                Behavior on border.color {
                                    ColorAnimation { duration: 500; easing.type: Easing.InOutQuad }
                                }
                            }

                            MouseArea {
                                anchors.fill: ring
                                onClicked: Atmosphere.path = modelData.path
                            }
                        }
                    }

                    CutieLabel {
                        visible: currentTab === 1 && customAtmospheres.length === 0
                        Layout.fillWidth: true
                        text: qsTr("Click the + icon to add custom themes")
                        font.pixelSize: 8
                        opacity: 0.9
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
