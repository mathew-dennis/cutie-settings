import Cutie
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Shared delegate for every Tumbler on this page.
component TumblerLabel: Text {
    property bool current: false
    property int  bigSize: 24
    property int  smallSize: 16
    property bool useBold: true

    font.pixelSize: current ? bigSize : smallSize
    font.bold: useBold && current
    opacity: current ? 1.0 : 0.5
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}

CutiePage {
    id: dateTimePage
    width: 400
    height: 800

    // ==========================================
    // MOCK BACKEND ENGINE (Replaces Cutie.Datetime)
    // ==========================================
    QtObject {
        id: CutieDateTime
        property bool ntpEnabled: false
        property string currentTimezone: "Asia/Dubai"

        signal errorOccurred(string message)

        function availableTimezones() {
            return [
                "UTC", 
                "Europe/London", 
                "Europe/Paris", 
                "America/New_York", 
                "Asia/Dubai", 
                "Asia/Kolkata", 
                "Asia/Tokyo", 
                "Australia/Sydney"
            ]
        }

        function setTime(date) {
            console.log("Mock Backend: System clock set to ->", date.toString())
        }

        function setNTP(enabled) {
            ntpEnabled = enabled
            console.log("Mock Backend: NTP Sync set to ->", enabled)
        }

        function setTimezone(tz) {
            currentTimezone = tz
            console.log("Mock Backend: System timezone altered to ->", tz)
        }
    }
    // ==========================================

    // Main App Background (Dark Blue/Grey)
    background: Rectangle {
        color: "#080E14"
    }

    // Common styling properties
    readonly property color cardColor: "#111C26"
    readonly property color accentColor: "#1DE9B6" // Cyan/Teal accent
    readonly property color textColor: "#FFFFFF"
    readonly property color subTextColor: "#8A9AA9"

    // Loads the tumblers with the device's current date/time.
    function syncTumblersToNow() {
        var now = new Date()
        hoursTumbler.currentIndex   = now.getHours()
        minutesTumbler.currentIndex = now.getMinutes()
        secondsTumbler.currentIndex = now.getSeconds()
        dayTumbler.currentIndex     = now.getDate() - 1   // model is 0-based
        monthTumbler.currentIndex   = now.getMonth()
        yearTumbler.currentIndex    = now.getFullYear() - 2000
    }

    Component.onCompleted: syncTumblersToNow()

    // Surfaces CutieDateTime.errorOccurred as a short banner under the header.
    Connections {
        target: CutieDateTime
        function onErrorOccurred(message) {
            errorBanner.text = message
            errorBanner.visible = true
            errorHideTimer.restart()
        }
    }

    Timer {
        id: errorHideTimer
        interval: 4000
        onTriggered: errorBanner.visible = false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // 1. Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            ToolButton {
                text: "←"
                font.pixelSize: 24
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: "#1A2530"
                    radius: 12
                    implicitWidth: 40
                    implicitHeight: 40
                }
            }

            Text {
                text: "Date & Time"
                color: textColor
                font.pixelSize: 22
                font.bold: true
                Layout.fillWidth: true
            }

            ToolButton {
                text: "⚙"
                font.pixelSize: 20
                onClicked: CutieDateTime.errorOccurred("Mock Error: Interactive Authentication failed (polkit denied access).")
                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: "#1A2530"
                    radius: 12
                    implicitWidth: 40
                    implicitHeight: 40
                }
            }
        }

        // Error feedback layout block
        Label {
            id: errorBanner
            Layout.fillWidth: true
            visible: false
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            color: "#FF6B6B"
            font.pixelSize: 12
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 15

                // 2. Time Setting Box (Hours, Minutes, Seconds)
                Rectangle {
                    Layout.fillWidth: true
                    height: 160
                    color: cardColor
                    radius: 16

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15

                        Text {
                            text: "Set Time"
                            color: textColor
                            font.pixelSize: 16
                            font.bold: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter

                            Tumbler {
                                id: hoursTumbler
                                model: 24
                                visibleItemCount: 3
                                delegate: TumblerLabel {
                                    text: modelData.toString().padStart(2, '0')
                                    color: textColor
                                    current: Tumbler.tumbler.currentIndex === index
                                }
                            }
                            Text { text: ":"; color: accentColor; font.pixelSize: 24; font.bold: true }
                            Tumbler {
                                id: minutesTumbler
                                model: 60
                                visibleItemCount: 3
                                delegate: TumblerLabel {
                                    text: modelData.toString().padStart(2, '0')
                                    color: textColor
                                    current: Tumbler.tumbler.currentIndex === index
                                }
                            }
                            Text { text: ":"; color: accentColor; font.pixelSize: 24; font.bold: true }
                            Tumbler {
                                id: secondsTumbler
                                model: 60
                                visibleItemCount: 3
                                delegate: TumblerLabel {
                                    text: modelData.toString().padStart(2, '0')
                                    color: textColor
                                    current: Tumbler.tumbler.currentIndex === index
                                }
                            }
                        }
                    }
                }

                // 3. Date Setting Box
                Rectangle {
                    Layout.fillWidth: true
                    height: 160
                    color: cardColor
                    radius: 16

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15

                        Text {
                            text: "Set Date"
                            color: textColor
                            font.pixelSize: 16
                            font.bold: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter

                            Tumbler {
                                id: dayTumbler
                                model: 31 
                                visibleItemCount: 3
                                delegate: TumblerLabel {
                                    text: (modelData + 1).toString().padStart(2, '0')
                                    color: textColor
                                    current: Tumbler.tumbler.currentIndex === index
                                    bigSize: 20
                                    smallSize: 14
                                    useBold: false
                                }
                            }
                            Tumbler {
                                id: monthTumbler
                                model: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                                visibleItemCount: 3
                                delegate: TumblerLabel {
                                    text: modelData
                                    color: textColor
                                    current: Tumbler.tumbler.currentIndex === index
                                    bigSize: 20
                                    smallSize: 14
                                    useBold: false
                                }
                            }
                            Tumbler {
                                id: yearTumbler
                                model: 50 // 2000-2049
                                visibleItemCount: 3
                                delegate: TumblerLabel {
                                    text: (modelData + 2000).toString()
                                    color: textColor
                                    current: Tumbler.tumbler.currentIndex === index
                                    bigSize: 20
                                    smallSize: 14
                                    useBold: false
                                }
                            }
                        }
                    }
                }

                // 4. Set / Reset Buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    Button {
                        Layout.fillWidth: true
                        text: "Reset"
                        onClicked: syncTumblersToNow()
                        contentItem: Text {
                            text: parent.text
                            color: textColor
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: "#1A2530"
                            radius: 12
                            implicitHeight: 50
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        text: "Set"
                        enabled: !CutieDateTime.ntpEnabled
                        opacity: enabled ? 1.0 : 0.5
                        onClicked: {
                            var picked = new Date(
                                yearTumbler.currentIndex + 2000,
                                monthTumbler.currentIndex,
                                dayTumbler.currentIndex + 1,
                                hoursTumbler.currentIndex,
                                minutesTumbler.currentIndex,
                                secondsTumbler.currentIndex
                            )
                            CutieDateTime.setTime(picked)
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#000000"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: accentColor
                            radius: 12
                            implicitHeight: 50
                        }
                    }
                }

                Text {
                    visible: CutieDateTime.ntpEnabled
                    text: "Turn off \"Automatic Date & Time\" to edit the clock manually."
                    color: subTextColor
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignHCenter
                }

                // 5. Automatic Date & Time (NTP)
                Rectangle {
                    Layout.fillWidth: true
                    height: 80
                    color: cardColor
                    radius: 16
                    Layout.topMargin: 10

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15

                        ColumnLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Automatic Date & Time"
                                color: textColor
                                font.pixelSize: 16
                                font.bold: true
                            }
                            Text {
                                text: "Sync time over the network (NTP)"
                                color: subTextColor
                                font.pixelSize: 12
                            }
                        }

                        // Direct instantaneous apply pattern
                        Switch {
                            id: ntpSwitch
                            checked: CutieDateTime.ntpEnabled
                            onToggled: CutieDateTime.setNTP(checked)

                            indicator: Rectangle {
                                implicitWidth: 50
                                implicitHeight: 26
                                x: ntpSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 13
                                color: ntpSwitch.checked ? accentColor : "#2C3E50"

                                Rectangle {
                                    x: ntpSwitch.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    width: 22
                                    height: 22
                                    radius: 11
                                    color: "#FFFFFF"
                                    Behavior on x { NumberAnimation { duration: 150 } }
                                }
                            }
                        }
                    }
                }

                // 6. Time Zone (Refactored to mirror instantaneous application)
                Rectangle {
                    Layout.fillWidth: true
                    height: 115
                    color: cardColor
                    radius: 16
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 8

                        Text {
                            text: "Time Zone"
                            color: textColor
                            font.pixelSize: 16
                            font.bold: true
                        }

                        ComboBox {
                            id: timezoneCombo
                            Layout.fillWidth: true
                            model: CutieDateTime.availableTimezones()
                            
                            // Declarative state binding: updates automatically if the backend value changes
                            currentIndex: model.indexOf(CutieDateTime.currentTimezone)

                            // Explicit user interaction patterns run immediately without a "Set" button
                            onActivated: CutieDateTime.setTimezone(currentText)

                            background: Rectangle {
                                color: "#0A1118"
                                radius: 12 // Standardized with the 12px layout button pattern
                                implicitHeight: 40
                                border.color: "#2C3E50"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.displayText
                                color: textColor
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                leftPadding: 10
                            }
                        }

                        Text {
                            text: "Applies immediately to the system clock."
                            color: subTextColor
                            font.pixelSize: 12
                        }
                    }
                }

                // Bottom padding
                Item { Layout.preferredHeight: 20 }
            }
        }
    }
}
