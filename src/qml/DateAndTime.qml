import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Cutie

CutiePage {
    id: dateTimePage
    title: qsTr("Time And Date")

    // =========================================================
    // 1. INLINE COMPONENTS (Must live inside the root element)
    // =========================================================
    component TumblerLabel: Text {
        property bool current: false
        font.pixelSize: current ? 22 : 16
        font.bold: current
        opacity: current ? 1.0 : 0.4
        color: Atmosphere.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    // =========================================================
    // 2. MOCK BACKEND ENGINE (Swap with your actual C++ plugin)
    // =========================================================
    QtObject {
        id: CutieDateTime
        property bool ntpEnabled: false
        property string currentTimezone: "Asia/Dubai"

        function availableTimezones() {
            return ["UTC", "Europe/London", "America/New_York", "Asia/Dubai", "Asia/Tokyo"]
        }
        function setTime(date) {
            console.log("System time updated to:", date.toString())
        }
        function setNTP(enabled) {
            ntpEnabled = enabled
            console.log("NTP synchronization:", enabled ? "Enabled" : "Disabled")
        }
        function setTimezone(tz) {
            currentTimezone = tz
            console.log("System timezone changed to:", tz)
        }
    }

    // =========================================================
    // 3. UTILITY FUNCTIONS
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
    // 4. UI LAYOUT
    // =========================================================
    ScrollView {
        anchors.fill: parent
        contentWidth: parent.width
        clip: true

        ColumnLayout {
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Item { Layout.preferredHeight: 10 } // Top padding buffer

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
                    checked: CutieDateTime.ntpEnabled
                    onToggled: CutieDateTime.setNTP(checked)
                }
            }

            // TIME PICKER (TUMBLERS)
            ColumnLayout {
                Layout.fillWidth: true
                visible: !CutieDateTime.ntpEnabled
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
                        delegate: TumblerLabel {
                            text: modelData.toString().padStart(2, '0')
                            current: Tumbler.tumbler.currentIndex === index
                        }
                    }
                    Text { text: ":"; color: Atmosphere.textColor; font.pixelSize: 20; opacity: 0.5 }
                    Tumbler {
                        id: minutesTumbler
                        model: 60
                        visibleItemCount: 3
                        delegate: TumblerLabel {
                            text: modelData.toString().padStart(2, '0')
                            current: Tumbler.tumbler.currentIndex === index
                        }
                    }
                    Text { text: ":"; color: Atmosphere.textColor; font.pixelSize: 20; opacity: 0.5 }
                    Tumbler {
                        id: secondsTumbler
                        model: 60
                        visibleItemCount: 3
                        delegate: TumblerLabel {
                            text: modelData.toString().padStart(2, '0')
                            current: Tumbler.tumbler.currentIndex === index
                        }
                    }
                }
            }

            // DATE PICKER (TUMBLERS)
            ColumnLayout {
                Layout.fillWidth: true
                visible: !CutieDateTime.ntpEnabled
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
                        delegate: TumblerLabel {
                            text: (modelData + 1).toString().padStart(2, '0')
                            current: Tumbler.tumbler.currentIndex === index
                        }
                    }
                    Tumbler {
                        id: monthTumbler
                        model: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                        visibleItemCount: 3
                        delegate: TumblerLabel {
                            text: modelData
                            current: Tumbler.tumbler.currentIndex === index
                        }
                    }
                    Tumbler {
                        id: yearTumbler
                        model: 50 // 2000 - 2049
                        visibleItemCount: 3
                        delegate: TumblerLabel {
                            text: (modelData + 2000).toString()
                            current: Tumbler.tumbler.currentIndex === index
                        }
                    }
                }
            }

            // ACTION BUTTONS
            RowLayout {
                Layout.fillWidth: true
                visible: !CutieDateTime.ntpEnabled
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
                        CutieDateTime.setTime(targetDate)
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
                    model: CutieDateTime.availableTimezones()
                    
                    // FIXED: Safe array evaluation bypassed internal QML wrapper limitations
                    currentIndex: CutieDateTime.availableTimezones().indexOf(CutieDateTime.currentTimezone)
                    
                    onActivated: CutieDateTime.setTimezone(currentText)
                }
            }

            Item { Layout.preferredHeight: 30 } // Bottom padding buffer
        }
    }
}
