import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Systeminfo

CutiePage {
    id: aboutPage

    readonly property color secondaryAlphaLightColor: Qt.rgba(
        Atmosphere.secondaryAlphaColor.r,
        Atmosphere.secondaryAlphaColor.g,
        Atmosphere.secondaryAlphaColor.b,
        0.1
    )

    property int commonHeight: 50
    property int cardRadius: 16
    property int cardPadding: 20

    // Backend Plugin Instantiation
    CutieSystemInfo {
        id: systemInfo
    }

    // Fixed Page Header stays on top
    CutiePageHeader {
        id: header
        title: qsTr("About")
        width: parent.width
    }

    // Scrollable content area
    Flickable {
        id: pageFlickable
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        contentHeight: mainColumn.height + 40
        clip: true

        Column {
            id: mainColumn
            width: parent.width
            spacing: 0

            Item { width: 1; height: 20 }

            // ── Branding Section ─────────────────────────────────────────
            Image {
                id: logo
                width: height * sourceSize.width / sourceSize.height
                height: (parent.width - 80) / 3
                anchors.horizontalCenter: parent.horizontalCenter
                source: "image://icon/cutie-shell"
            }

            Item { width: 1; height: 10 }

            CutieLabel {
                text: "Cutie Shell"
                font.pixelSize: 20
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item { width: 1; height: 32 }

            // ── Software Information Card ────────────────────────────────
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: softwareLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius

                ColumnLayout {
                    id: softwareLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 14

                    CutieLabel {
                        text: qsTr("Software Information")
                        font.bold: true
                        font.pixelSize: 16
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        InfoRow { label: qsTr("OS Name"); value: systemInfo.osInfo.osName }
                        InfoRow { label: qsTr("Kernel Version"); value: systemInfo.osInfo.kernel }
                        InfoRow { label: qsTr("Build Version"); value: systemInfo.osInfo.build }
                        InfoRow { label: qsTr("Update Channel"); value: systemInfo.osInfo.channel }
                    }
                }
            }

            Item { width: 1; height: 24 }

            // ── Hardware Information Card ────────────────────────────────
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: hardwareLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius

                ColumnLayout {
                    id: hardwareLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 14

                    CutieLabel {
                        text: qsTr("Hardware Information")
                        font.bold: true
                        font.pixelSize: 16
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        InfoRow { label: qsTr("Device Model"); value: systemInfo.hwInfo.device }
                        InfoRow { label: qsTr("Processor"); value: systemInfo.hwInfo.processor }
                        InfoRow { label: qsTr("Memory"); value: systemInfo.hwInfo.memory }
                        InfoRow { label: qsTr("Storage Capacity"); value: systemInfo.hwInfo.storage }
                        InfoRow { label: qsTr("Display Resolution"); value: systemInfo.hwInfo.display }
                        InfoRow { label: qsTr("Battery Status"); value: systemInfo.hwInfo.battery }
                    }
                }
            }

            Item { width: 1; height: 24 }
        }
    }

    // ── Inline Row Component with Overflow Safety ─────────────────────
    component InfoRow : RowLayout {
        id: rowRoot
        property string label: ""
        property string value: ""

        Layout.fillWidth: true
        spacing: 12

        CutieLabel {
            text: rowRoot.label
            font.pixelSize: 14
            opacity: 0.7
            Layout.preferredWidth: parent.width * 0.35
            elide: Text.ElideRight
        }

        CutieLabel {
            text: rowRoot.value
            font.pixelSize: 14
            font.bold: true
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            
            // Fix: Cleanly cuts off ultra-long system strings using "..."
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }
}
