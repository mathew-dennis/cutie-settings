import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Store

CutiePage {
    id: dateAndTimePage

    // ── Design System Constants (Matched to your Reference Page) ──────────
    readonly property color secondaryAlphaLightColor: Qt.rgba (
        Atmosphere.secondaryAlphaColor.r,
        Atmosphere.secondaryAlphaColor.g,
        Atmosphere.secondaryAlphaColor.b,
        0.1
    )
    property int commonHeight: 50
    property int cardRadius: 16
    property int cardPadding: 20

    // ── Properties & State Bindings ─────────────────────────────────────
    property bool isAutomatic: dateTimeStore.data && ("isAutomatic" in dateTimeStore.data)
                               ? dateTimeStore.data.isAutomatic
                               : false

    property string currentTimezone: dateTimeStore.data && ("timezone" in dateTimeStore.data)
                                     ? dateTimeStore.data.timezone
                                     : "Asia/Dubai"

    property var availableTimezones: ["UTC", "Europe/London", "America/New_York", "Asia/Dubai", "Asia/Tokyo"]

    // ── Helper Functions ────────────────────────────────────────────────
    function syncTumblersToNow() {
        var now = new Date()
        hoursTumbler.currentIndex   = now.getHours()
        minutesTumbler.currentIndex = now.getMinutes()
        secondsTumbler.currentIndex = now.getSeconds()
        dayTumbler.currentIndex     = now.getDate() - 1 
        monthTumbler.currentIndex   = now.getMonth()
        yearTumbler.currentIndex    = now.getFullYear() - 2000
    }

    Component.onCompleted: syncTumblersToNow()

    // ── Layout Tree ──────────────────────────────────────────────────────
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
                title: qsTr("Time And Date")
                width: parent.width
            }

            Item { width: 1; height: 24 }

            // ── Card 1: Set Automatically (NTP Switch) ───────────────────
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: ntpLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius

                RowLayout {
                    id: ntpLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 16

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        CutieLabel {
                            text: qsTr("Set Automatically")
                            font.bold: true
                            font.pixelSize: 16
                        }

                        CutieLabel {
                            text: qsTr("Use network-provided time (NTP)")
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
                            id: automaticToggle
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: dateAndTimePage.isAutomatic

                            onToggled: {
                                let d = dateTimeStore.data
                                d.isAutomatic = checked
                                dateTimeStore.data = d
                                console.log("System time sync updated:", checked ? "Automatic" : "Manual")
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 24 }

            // ── Card 2: Unified Date & Time Picker Box ───────────────────
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: pickerLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius
                visible: !automaticToggle.checked // Hidden when Automatic is checked

                ColumnLayout {
                    id: pickerLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 20

                    // Time Picker Sub-Section
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        CutieLabel {
                            text: qsTr("Time Configuration")
                            font.bold: true
                            font.pixelSize: 14
                            opacity: 0.8
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 10

                            Tumbler {
                                id: hoursTumbler
                                model: 24
                                visibleItemCount: 3
                                delegate: Text {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    font.pixelSize: hoursTumbler.currentIndex === index ? 22 : 16
                                    font.bold: hoursTumbler.currentIndex === index
                                    opacity: hoursTumbler.currentIndex === index ? 1.0 : 0.4
                                    color: Atmosphere.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Text { text: ":"; color: Atmosphere.textColor; font.pixelSize: 20; opacity: 0.5 }
                            Tumbler {
                                id: minutesTumbler
                                model: 60
                                visibleItemCount: 3
                                delegate: Text {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    font.pixelSize: minutesTumbler.currentIndex === index ? 22 : 16
                                    font.bold: minutesTumbler.currentIndex === index
                                    opacity: minutesTumbler.currentIndex === index ? 1.0 : 0.4
                                    color: Atmosphere.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Text { text: ":"; color: Atmosphere.textColor; font.pixelSize: 20; opacity: 0.5 }
                            Tumbler {
                                id: secondsTumbler
                                model: 60
                                visibleItemCount: 3
                                delegate: Text {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    font.pixelSize: secondsTumbler.currentIndex === index ? 22 : 16
                                    font.bold: secondsTumbler.currentIndex === index
                                    opacity: secondsTumbler.currentIndex === index ? 1.0 : 0.4
                                    color: Atmosphere.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }

                    // Separation line spacer
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Atmosphere.secondaryAlphaColor
                        opacity: 0.2
                    }

                    // Date Picker Sub-Section
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        CutieLabel {
                            text: qsTr("Date Configuration")
                            font.bold: true
                            font.pixelSize: 14
                            opacity: 0.8
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 15

                            Tumbler {
                                id: dayTumbler
                                model: 31
                                visibleItemCount: 3
                                delegate: Text {
                                    text: ((modelData + 1) < 10 ? "0" : "") + (modelData + 1)
                                    font.pixelSize: dayTumbler.currentIndex === index ? 22 : 16
                                    font.bold: dayTumbler.currentIndex === index
                                    opacity: dayTumbler.currentIndex === index ? 1.0 : 0.4
                                    color: Atmosphere.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Tumbler {
                                id: monthTumbler
                                model: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                                visibleItemCount: 3
                                delegate: Text {
                                    text: modelData
                                    font.pixelSize: monthTumbler.currentIndex === index ? 22 : 16
                                    font.bold: monthTumbler.currentIndex === index
                                    opacity: monthTumbler.currentIndex === index ? 1.0 : 0.4
                                    color: Atmosphere.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Tumbler {
                                id: yearTumbler
                                model: 50 
                                visibleItemCount: 3
                                delegate: Text {
                                    text: (modelData + 2000).toString()
                                    font.pixelSize: yearTumbler.currentIndex === index ? 22 : 16
                                    font.bold: yearTumbler.currentIndex === index
                                    opacity: yearTumbler.currentIndex === index ? 1.0 : 0.4
                                    color: Atmosphere.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }
            }

            // ── Action Buttons Block (Positioned Safely Below Card 2 Box) ──
            Item { width: 1; height: 14; visible: !automaticToggle.checked }
            RowLayout {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14
                visible: !automaticToggle.checked

                CutieButton {
                    Layout.fillWidth: true
                    implicitHeight: commonHeight
                    text: qsTr("Reset")
                    onClicked: syncTumblersToNow()
                }

                CutieButton {
                    Layout.fillWidth: true
                    implicitHeight: commonHeight
                    text: qsTr("Apply Changes")
                    
                    // Styled background match to highlight affirmative actions
                    background: Rectangle {
                        color: Atmosphere.primaryColor
                        radius: 8
                    }

                    onClicked: {
                        var targetDate = new Date(
                            yearTumbler.currentIndex + 2000,
                            monthTumbler.currentIndex,
                            dayTumbler.currentIndex + 1,
                            hoursTumbler.currentIndex,
                            minutesTumbler.currentIndex,
                            secondsTumbler.currentIndex
                        )
                        console.log("Manual system time committed to:", targetDate.toString())
                    }
                }
            }

            Item { width: 1; height: 24; visible: !automaticToggle.checked }

            // ── Card 3: Manual Time Zone Card ────────────────────────────
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: tzLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius
                visible: !automaticToggle.checked // Only visible when automatic mode is unchecked

                ColumnLayout {
                    id: tzLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 12

                    CutieLabel {
                        text: qsTr("Time Zone")
                        font.bold: true
                        font.pixelSize: 16
                    }

                    ComboBox {
                        id: timezoneCombo
                        Layout.fillWidth: true
                        model: dateAndTimePage.availableTimezones
                        currentIndex: dateAndTimePage.availableTimezones.indexOf(dateAndTimePage.currentTimezone)
                        
                        onActivated: {
                            let d = dateTimeStore.data
                            d.timezone = currentText
                            dateTimeStore.data = d
                            console.log("System timezone changed to:", currentText)
                        }
                    }
                }
            }

            Item { width: 1; height: 24 }
        }
    }

    // ── Persistent Storage Context ───────────────────────────────────────
    CutieStore {
        id: dateTimeStore
        appName: "cutie-settings"
        storeName: "datetimeConfigs"
    }
}
