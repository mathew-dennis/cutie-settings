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
    property int tabHeight:   44
    property var newAtmosphereComponent: Qt.createComponent("NewAtmosphere.qml")
    property var newAtmospherePopup: null
    property string deleteTargetPath: ""

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

    onCurrentTabChanged: deleteTargetPath = ""

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
                                font.pixelSize: 16
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
                        Layout.preferredHeight: 150
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
                                width: 150
                                height: 150

                                Rectangle {
                                    x: 24
                                    y: 9
                                    width: 102
                                    height: 132
                                    radius: 8
                                    color: "transparent"
                                    border.color: Atmosphere.textColor
                                    border.width: 1
                                    opacity: 0.6

                                    Text {
                                        anchors.centerIn: parent
                                        text: "+"
                                        font.pixelSize: 48
                                        font.family: "Lato"
                                        color: Atmosphere.textColor
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (newAtmosphereComponent.status === Component.Ready) {
                                                if (!newAtmospherePopup)
                                                    newAtmospherePopup = newAtmosphereComponent.createObject(atmospherePage)
                                                if (newAtmospherePopup) {
                                                    newAtmospherePopup.reset()
                                                    newAtmospherePopup.open()
                                                }
                                            } else if (newAtmosphereComponent.status === Component.Error) {
                                                console.warn("New atmosphere popup failed to load:", newAtmosphereComponent.errorString())
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        delegate: Item {
                            width: 150
                            height: 150

                            readonly property bool isSelected: modelData.path === Atmosphere.path

                            Image {
                                id: wallpaper
                                x: 30
                                y: 15
                                width: 90
                                height: 120
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

                                MouseArea {
                                    anchors.fill: parent
                                    property bool held: false
                                    onPressed: held = false
                                    onPressAndHold: {
                                        if (modelData.editable === true) {
                                            held = true
                                            deleteTargetPath = modelData.path
                                        }
                                    }
                                    onClicked: {
                                        if (!held)
                                            Atmosphere.path = modelData.path
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    visible: deleteTargetPath !== modelData.path
                                    font.pixelSize: 14
                                    font.family: "Lato"
                                    color: (modelData.variant === "dark") ? "#FFFFFF" : "#000000"
                                }

                                CutieButton {
                                    anchors.centerIn: parent
                                    width: 40
                                    height: 40
                                    visible: deleteTargetPath === modelData.path
                                    icon.name: "user-trash-symbolic"
                                    icon.color: "#ff3b30"
                                    icon.width: 24
                                    icon.height: 24
                                    background: Rectangle {
                                        radius: 8
                                        color: Qt.rgba(0, 0, 0, 0.55)
                                        border.color: "#ff3b30"
                                        border.width: 1
                                    }
                                    onClicked: {
                                        deleteConfirmation.atmosphereName = modelData.name
                                        deleteConfirmation.errorText = ""
                                        deleteConfirmation.open()
                                    }
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
                                border.color: deleteTargetPath === modelData.path
                                              ? "#ff3b30" : Atmosphere.textColor
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

    Popup {
        id: deleteConfirmation
        anchors.centerIn: parent
        width: Math.min(parent ? parent.width - 32 : 320, 360)
        modal: true
        focus: true
        padding: 20
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        property string atmosphereName: ""
        property string errorText: ""

        background: Rectangle {
            radius: 16
            color: Atmosphere.primaryColor
            border.color: Atmosphere.textColor
            border.width: 1
        }

        contentItem: ColumnLayout {
            spacing: 16

            CutieLabel {
                Layout.fillWidth: true
                text: qsTr("Do you want to delete this theme?")
                wrapMode: Text.WordWrap
                font.pixelSize: 16
            }

            CutieLabel {
                Layout.fillWidth: true
                visible: deleteConfirmation.errorText !== ""
                text: deleteConfirmation.errorText
                color: "#ff5555"
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                CutieButton {
                    Layout.fillWidth: true
                    text: qsTr("Cancel")
                    onClicked: deleteConfirmation.close()
                }

                CutieButton {
                    Layout.fillWidth: true
                    text: qsTr("Delete")
                    onClicked: {
                        if (Atmosphere.deleteAtmosphere(deleteConfirmation.atmosphereName)) {
                            deleteTargetPath = ""
                            deleteConfirmation.close()
                        } else {
                            deleteConfirmation.errorText = qsTr("Couldn't delete this theme.")
                        }
                    }
                }
            }
        }
    }
}
