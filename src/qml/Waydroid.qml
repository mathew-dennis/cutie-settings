import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Waydroid

CutiePage {
    id: waydroidSettingsPage

    readonly property color secondaryAlphaLightColor: Qt.rgba(
        Atmosphere.secondaryAlphaColor.r,
        Atmosphere.secondaryAlphaColor.g,
        Atmosphere.secondaryAlphaColor.b,
        0.1
    )

    property int commonHeight: 50
    property int cardRadius: 16
    property int cardPadding: 20

    property var appsModel: null

    Component.onCompleted: {
        CutieWaydroidManager.refreshStatus()
        appsModel = CutieWaydroidManager.fetchInstalledApps()
    }

    Connections {
        target: CutieWaydroidManager
        function onInstallFinished(success, message) {
            installNote.text = success ? qsTr("App installed.") : message
            if (success && waydroidSettingsPage.appsModel)
                waydroidSettingsPage.appsModel.refresh()
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

            // ── Page Header ─────────────────────────────────────────────
            CutiePageHeader {
                id: header
                title: qsTr("Waydroid")
                width: parent.width
            }

            Item { width: 1; height: 24 }

            // ── Status / Power Card ───────────────────────────────────────
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: statusLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius

                ColumnLayout {
                    id: statusLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 14

                    CutieLabel {
                        text: qsTr("Run Android Apps")
                        font.bold: true
                        font.pixelSize: 16
                    }

                    CutieLabel {
                        text: qsTr("Waydroid lets you install and run Android apps alongside the rest of the system.")
                        font.pixelSize: 13
                        opacity: 0.9
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    // -- Not initialized yet: explain + offer to set it up --
                    ColumnLayout {
                        visible: !CutieWaydroidManager.initialized
                        Layout.fillWidth: true
                        spacing: 10

                        CutieLabel {
                            text: qsTr("Waydroid hasn't been set up on this device yet. This downloads the Android system image and only needs to happen once.")
                            font.pixelSize: 13
                            opacity: 0.7
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        CutieButton {
                            text: qsTr("Initialize Waydroid")
                            Layout.fillWidth: true
                            implicitHeight: commonHeight
                            enabled: !CutieWaydroidManager.busy
                            onClicked: CutieWaydroidManager.initWaydroid()
                        }
                    }

                    // -- Initialized: on/off row, mirrors the Panel Mode toggle row --
                    RowLayout {
                        visible: CutieWaydroidManager.initialized
                        Layout.fillWidth: true
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            CutieLabel {
                                text: qsTr("Waydroid")
                                font.pixelSize: 14
                            }
                            CutieLabel {
                                text: CutieWaydroidManager.running ? qsTr("Running") : qsTr("Stopped")
                                font.pixelSize: 12
                                opacity: 0.7
                            }
                        }

                        BusyIndicator {
                            visible: CutieWaydroidManager.busy
                            running: visible
                            implicitWidth: 22
                            implicitHeight: 22
                        }

                        Item {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 30

                            CutieToggle {
                                id: waydroidToggle
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter

                                enabled: !CutieWaydroidManager.busy
                                checked: CutieWaydroidManager.running

                                onToggled: {
                                    if (checked) {
                                        CutieWaydroidManager.startWaydroid()
                                    } else {
                                        CutieWaydroidManager.stopWaydroid()
                                    }
                                }
                            }
                        }
                    }

                    CutieLabel {
                        visible: text.length > 0
                        text: CutieWaydroidManager.lastError
                        color: "#e05c5c"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    CutieLabel {
                        id: liveStatusLabel
                        visible: CutieWaydroidManager.busy && text.length > 0
                        font.pixelSize: 12
                        opacity: 0.7
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true

                        Connections {
                            target: CutieWaydroidManager
                            function onStatusMessage(message) { liveStatusLabel.text = message }
                        }
                    }
                }
            }

            // Note
            Item { width: 1; height: 10 }
            CutieLabel {
                text: qsTr("Note: turning Waydroid off stops the Android session and container to free up memory; turning it back on restarts both automatically.")
                font.pixelSize: 11
                opacity: 0.7
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
            }

            Item { width: 1; height: 24 }

            // ── Install APK Card ─────────────────────────────────────────
            Rectangle {
                visible: CutieWaydroidManager.initialized
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: installLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius

                ColumnLayout {
                    id: installLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 14

                    CutieLabel {
                        text: qsTr("Install an App")
                        font.bold: true
                        font.pixelSize: 16
                    }

                    CutieLabel {
                        text: qsTr("Sideload an Android app from an APK file.")
                        font.pixelSize: 13
                        opacity: 0.9
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    CutieButton {
                        text: qsTr("Install APK…")
                        Layout.fillWidth: true
                        implicitHeight: commonHeight
                        enabled: !CutieWaydroidManager.installInProgress
                        onClicked: {
                            // Wire filePicker.selectedPath up to this project's
                            // existing file-picker component:
                            // CutieWaydroidManager.installApp(filePicker.selectedPath)
                        }
                    }

                    CutieLabel {
                        id: installNote
                        visible: text.length > 0
                        font.pixelSize: 12
                        opacity: 0.7
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }

            Item { width: 1; height: 24 }

            // ── Installed Apps Card ──────────────────────────────────────
            Rectangle {
                visible: CutieWaydroidManager.initialized
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
                        visible: waydroidSettingsPage.appsModel && waydroidSettingsPage.appsModel.rowCount === 0
                        text: qsTr("No apps installed yet.")
                        font.pixelSize: 13
                        opacity: 0.7
                        Layout.fillWidth: true
                    }

                    Repeater {
                        model: waydroidSettingsPage.appsModel

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Image {
                                    source: icon && icon.length > 0
                                            ? (icon.startsWith("/") ? "file://" + icon : "image://theme/" + icon)
                                            : ""
                                    Layout.preferredWidth: 36
                                    Layout.preferredHeight: 36
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                }

                                CutieLabel {
                                    text: name
                                    font.pixelSize: 14
                                    opacity: hidden ? 0.5 : 1.0
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                CutieButton {
                                    text: hidden ? qsTr("Show") : qsTr("Hide")
                                    implicitHeight: commonHeight - 14
                                    onClicked: waydroidSettingsPage.appsModel.toggleHidden(index)
                                }

                                CutieButton {
                                    text: qsTr("Uninstall")
                                    implicitHeight: commonHeight - 14
                                    onClicked: waydroidSettingsPage.appsModel.uninstallApp(index)
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: Atmosphere.secondaryAlphaColor
                                opacity: 0.2
                                visible: index < waydroidSettingsPage.appsModel.rowCount - 1
                            }
                        }
                    }
                }
            }

            // Note
            Item { width: 1; height: 10 }
            CutieLabel {
                text: qsTr("Note: hiding an app only removes it from the app drawer - it stays installed and can be shown again anytime.")
                font.pixelSize: 11
                opacity: 0.7
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
            }

            Item { width: 1; height: 24 }
        }
    }
}
