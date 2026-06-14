import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Cutie

CutiePage {
    id: dateTimePage
    title: qsTr("Time And Date")

    // =========================================================
    // 1. MOCK BACKEND ENGINE (Safe structural properties)
    // =========================================================
    QtObject {
        id: cutieDateTimeBackend
        property bool ntpEnabled: false
        property string currentTimezone: "Asia/Dubai"
        property var timezones: ["UTC", "Europe/London", "America/New_York", "Asia/Dubai", "Asia/Tokyo"]
    }

    // =========================================================
    // 2. UTILITY FUNCTIONS (Vanilla JS compatibility)
    // =========================================================
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

    // =========================================================
    // 3. UI LAYOUT
    // =========================================================
    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        clip: true

        ColumnLayout {
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Item { Layout.preferredHeight: 10 } // Top spacing buffer

            // AUTOMATIC NTP SYNC SWITCH
            RowLayout {
                Layout.fillWidth: true
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: qsTr("Set Automatically")
                        font.pixelSize: 16
                        font.bold: true
                        color: Atmosphere.textColor
                    }
                    Text {
                        text: qsTr("Use network-provided time (NTP)")
                        font.pixelSize: 12
                        color: Atmosphere.textColor
                        opacity: 0.6
                    }
                }

                Switch {
                    id: ntpSwitch
                    checked: cutieDateTimeBackend.ntpEnabled
                    onToggled: cutieDateTimeBackend.ntpEnabled = checked
                }
            }

            // TIME PICKER (TUMBLERS)
            ColumnLayout {
                Layout.fillWidth: true
                visible: !ntpSwitch.checked
                spacing: 8

                Text {
                    text: qsTr("Time")
                    font.pixelSize: 14
                    font.bold: true
                    color: Atmosphere.textColor
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

            // DATE PICKER (TUMBLERS)
            ColumnLayout {
                Layout.fillWidth: true
                visible: !ntpSwitch.checked
                spacing: 8

                Text {
                    text: qsTr("Date")
                    font.pixelSize: 14
                    font.bold: true
                    color: Atmosphere.textColor
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

            // ACTION BUTTONS
            RowLayout {
                Layout.fillWidth: true
                visible: !ntpSwitch.checked
                spacing: 15
                Layout.topMargin: 10

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Reset")
                    onClicked: syncTumblersToNow()
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Apply Changes")
                    onClicked: {
                        var targetDate = new Date(
                            yearTumbler.currentIndex + 2000,
                            monthTumbler.currentIndex,
                            dayTumbler.currentIndex + 1,
                            hoursTumbler.currentIndex,
                            minutesTumbler.currentIndex,
                            secondsTumbler.currentIndex
                        )
                        console.log("System time updated to:", targetDate.toString())
                    }
                }
            }

            // TIME ZONE SELECTION
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                Layout.topMargin: 15

                Text {
                    text: qsTr("Time Zone")
                    font.pixelSize: 16
                    font.bold: true
                    color: Atmosphere.textColor
                }

                ComboBox {
                    id: timezoneCombo
                    Layout.fillWidth: true
                    model: cutieDateTimeBackend.timezones
                    currentIndex: 3 // "Asia/Dubai" fallback index to prevent lookup cycles
                }
            }

            Item { Layout.preferredHeight: 30 } // Bottom spacing buffer
        }
    }
}
