import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Store

CutiePage {
    id: dateAndTimePage

    // ── Design System Constants ──────────────────────────────────────────
    readonly property color secondaryAlphaLightColor: Qt.rgba (
        Atmosphere.secondaryAlphaColor.r,
        Atmosphere.secondaryAlphaColor.g,
        Atmosphere.secondaryAlphaColor.b,
        0.1
    )
    property int commonHeight: 50
    property int cardRadius: 16
    property int cardPadding: 14 // Reduced from 20 to make the cards smaller

    // ── Safe Backward-Compatible Models for Dropdowns ───────────────────
    property var daysModel: []
    property var monthsModel: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    property var yearsModel: []

    // ── Properties & State Bindings ─────────────────────────────────────
    property bool isAutomatic: dateTimeStore.data && ("isAutomatic" in dateTimeStore.data)
                               ? dateTimeStore.data.isAutomatic
                               : false

    property string currentTimezone: dateTimeStore.data && ("timezone" in dateTimeStore.data)
                                     ? dateTimeStore.data.timezone
                                     : "Asia/Dubai"

    property var availableTimezones: ["UTC", "Europe/London", "America/New_York", "Asia/Dubai", "Asia/Tokyo"]

    // ── Helper Functions ────────────────────────────────────────────────
    function syncInputsToNow() {
        var now = new Date()
        
        // Sync Time Tumblers
        hoursTumbler.currentIndex   = now.getHours()
        minutesTumbler.currentIndex = now.getMinutes()
        secondsTumbler.currentIndex = now.getSeconds()
        
        // Sync Date Dropdowns
        dayCombo.currentIndex   = now.getDate() - 1
        monthCombo.currentIndex = now.getMonth()
        yearCombo.currentIndex  = now.getFullYear() - 2000
    }

    Component.onCompleted: {
        // Safely populate dropdown models loop for older JS engines
        var d = []; for (var i = 1; i <= 31; i++) { d.push(i < 10 ? "0" + i : i.toString()); }
        daysModel = d;

        var y = []; for (var j = 2000; j <= 2049; j++) { y.push(j.toString()); }
        yearsModel = y;

        syncInputsToNow()
    }

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

            Item { width: 1; height: 16 }

            // ── Card 1: Compact Date & Time Picker Box ───────────────────
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: pickerLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius

                ColumnLayout {
                    id: pickerLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 12
                    // Inputs grey out/disable when Automatic time is on, but card stays visible
                    enabled: !automaticToggle.checked 

                    // Time Section (Tumblers brought closer together)
                    RowLayout {
                        Layout.fillWidth: true
                        
                        CutieLabel {
                            text: qsTr("Time")
                            font.bold: true
                            font.pixelSize: 14
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            spacing: 4

                            Tumbler {
                                id: hoursTumbler
                                model: 24
                                visibleItemCount: 3
                                height: 70 // Forced short container height to compress layout
                                delegate: Text {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    implicitHeight: 22 // Tight item height pulls numbers closer
                                    font.pixelSize: hoursTumbler.currentIndex === index ? 18 : 14
                                    font.bold: hoursTumbler.currentIndex === index
                                    opacity: hoursTumbler.currentIndex === index ? 1.0 : 0.3
                                    color: Atmosphere.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Text { text: ":"; color: Atmosphere.textColor; font.pixelSize: 16; opacity: 0.5 }
                            Tumbler {
                                id: minutesTumbler
                                model: 60
                                visibleItemCount: 3
                                height: 70
                                delegate: Text {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    implicitHeight: 22
                                    font.pixelSize: minutesTumbler.currentIndex === index ? 18 : 14
                                    font.bold: minutesTumbler.currentIndex === index
                                    opacity: minutesTumbler.currentIndex === index ? 1.0 : 0.3
                                    color: Atmosphere.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            Text { text: ":"; color: Atmosphere.textColor; font.pixelSize: 16; opacity: 0.5 }
                            Tumbler {
                                id: secondsTumbler
                                model: 60
                                visibleItemCount: 3
                                height: 70
                                delegate: Text {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    implicitHeight: 22
                                    font.pixelSize: secondsTumbler.currentIndex === index ? 18 : 14
                                    font.bold: secondsTumbler.currentIndex === index
                                    opacity: secondsTumbler.currentIndex === index ? 1.0 : 0.3
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
                        opacity: 0.15
                    }

                    // Date Section (Replaced with Dropdown lists)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        CutieLabel {
                            text: qsTr("Date")
                            font.bold: true
                            font.pixelSize: 14
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            ComboBox {
                                id: dayCombo
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                model: dateAndTimePage.daysModel
                            }

                            ComboBox {
                                id: monthCombo
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1.2
                                model: dateAndTimePage.monthsModel
                            }

                            ComboBox {
                                id: yearCombo
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1.3
                                model: dateAndTimePage.yearsModel
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 16 }

            // ── Card 2: Set Automatically (Moved below Date & Time Card) ──
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
                        spacing: 4

                        CutieLabel {
                            text: qsTr("Set Automatically")
                            font.bold: true
                            font.pixelSize: 15
                        }

                        CutieLabel {
                            text: qsTr("Use network-provided time (NTP)")
                            font.pixelSize: 12
                            opacity: 0.6
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

            // ── Action Buttons Block (ONLY hidden part when Toggled) ──────
            Item { width: 1; height: 14; visible: !automaticToggle.checked }
            RowLayout {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14
                visible: !automaticToggle.checked // Hides completely when auto time is enabled

                CutieButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1 // Forces explicit matching proportional sizing
                    implicitHeight: commonHeight
                    text: qsTr("Reset")
                    onClicked: syncInputsToNow()
                }

                CutieButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1 // Perfectly balances layout width with Reset button
                    implicitHeight: commonHeight
                    text: qsTr("Apply Changes")
                    
                    background: Rectangle {
                        color: Atmosphere.primaryColor
                        radius: 8
                    }

                    onClicked: {
                        var targetDate = new Date(
                            yearCombo.currentIndex + 2000,
                            monthCombo.currentIndex,
                            dayCombo.currentIndex + 1,
                            hoursTumbler.currentIndex,
                            minutesTumbler.currentIndex,
                            secondsTumbler.currentIndex
                        )
                        console.log("Manual system time committed to:", targetDate.toString())
                    }
                }
            }

            Item { width: 1; height: 16 }

            // ── Card 3: Manual Time Zone Card (Stays Visible) ────────────
            Rectangle {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                height: tzLayout.implicitHeight + cardPadding * 2
                color: secondaryAlphaLightColor
                radius: cardRadius
                enabled: !automaticToggle.checked

                ColumnLayout {
                    id: tzLayout
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 8

                    CutieLabel {
                        text: qsTr("Time Zone")
                        font.bold: true
                        font.pixelSize: 15
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
