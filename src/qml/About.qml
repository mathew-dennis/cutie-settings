import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

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

                        // Hardcoded values for static UI visual testing
                        InfoRow { label: qsTr("OS Name");        value: "Droidian Linux" }
                        InfoRow { label: qsTr("Kernel Version"); value: "4.19.157-cutie-core" }
                        InfoRow { label: qsTr("Build Version");  value: "20260613-bookworm" }
                        InfoRow { label: qsTr("Update Channel"); value: "Testing" }
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

                        // Hardcoded values for static UI visual testing
                        InfoRow { label: qsTr("Device Model");      value: "Galaxy S20 FE" }
                        InfoRow { label: qsTr("Processor");         value: "Snapdragon 865" }
                        InfoRow { label: qsTr("Memory");            value: "6.0 GB" }
                        InfoRow { label: qsTr("Storage Capacity");  value: "128 GB" }
                        InfoRow { label: qsTr("Display Resolution"); value: "1080x2400" }
                        InfoRow { label: qsTr("Battery Status");    value: "85%" }
                    }
                }
            }

            Item { width: 1; height: 24 }
        }
    }

    // ── Inline Row Component for Layout Consistency ─────────────────────
    component InfoRow : RowLayout {
        id: rowRoot
        property string label: ""
        property string value: ""

        Layout.fillWidth: true
        height: 24

        CutieLabel {
            text: rowRoot.label
            font.pixelSize: 14
            opacity: 0.7
            Layout.fillWidth: true
        }

        CutieLabel {
            text: rowRoot.value
            font.pixelSize: 14
            font.bold: true
            Layout.alignment: Qt.AlignRight
            horizontalAlignment: Text.AlignRight
        }
    }
}