import Cutie
import Cutie.Desktopfileparser
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

CutiePage {
    id: appsPage

    readonly property color secondaryAlphaLightColor: Qt.rgba(
        Atmosphere.secondaryAlphaColor.r,
        Atmosphere.secondaryAlphaColor.g,
        Atmosphere.secondaryAlphaColor.b,
        0.1
    )

    property int commonHeight: 50
    property int cardRadius:   16
    property int cardPadding:  20

    property var appsModel: null

    Component.onCompleted: {
        appsModel = CutieDesktopFileParser.fetchAllEntriesModel()
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
                title: qsTr("Applications")
                width: parent.width
            }

            Item { width: 1; height: 24 }

            // ── Apps Card ────────────────────────────────────────────────
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: appsLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius

                ColumnLayout {
                    id: appsLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 14

                    CutieLabel {
                        text: qsTr("Installed Apps")
                        font.bold: true
                        font.pixelSize: 16
                    }

                    CutieLabel {
                        visible: appsPage.appsModel === null
                        text: qsTr("Loading…")
                        font.pixelSize: 13
                        opacity: 0.7
                        Layout.fillWidth: true
                    }

                    Repeater {
                        id: appRepeater
                        model: appsPage.appsModel

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                CutieButton {
                                    icon.name: model.icon
                                    icon.source: "file://" + model.icon
                                    icon.width: 18
                                    icon.height: 18
                                    implicitWidth: 28
                                    implicitHeight: 28
                                    background: null
                                    onClicked: compositor.execApp(model.exec)
                                }

                                CutieLabel {
                                    text: model.name
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                CutieButton {
                                    text: qsTr("Open")
                                    implicitHeight: commonHeight - 14
                                    onClicked: compositor.execApp(model.exec)
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: Atmosphere.secondaryAlphaColor
                                opacity: 0.2
                                visible: index < appRepeater.count - 1
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 24 }
        }
    }
}