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
    property int cardPadding: 14 

    // ── Static & Safe Initialization Models ──────────────────────────────
    property var daysModel: ["01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
    property var monthsModel: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    property var yearsModel: ["2024","2025","2026","2027","2028","2029","2030","2031","2032","2033","2034","2035","2036","2037","2038","2039","2040"]

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
        
        hoursTumbler.currentIndex   = now.getHours()
        minutesTumbler.currentIndex = now.getMinutes()
        
        dayCombo.currentIndex   = now.getDate() - 1
        monthCombo.currentIndex = now.getMonth()
        
        var yearIdx = yearsModel.indexOf(now.getFullYear().toString())
        if (yearIdx !== -1) {
            yearCombo.currentIndex = yearIdx
        }
    }

    Component.onCompleted: syncInputsToNow()

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
                enabled: !automaticToggle.checked 

                ColumnLayout {
                    id: pickerLayout
                    width: parent.width - 32
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: cardPadding
                    }
                    spacing: 16

                    // Transparent Framing Box with Borderline
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: timeRowLayout.implicitWidth + 40
                        implicitHeight: timeRowLayout.implicitHeight + 16
                        color: transparent
                        border.color: Qt.rgba(Atmosphere.textColor.r, Atmosphere.textColor.g, Atmosphere.textColor.b, 0.25)
                        border.width: 1.5
                        radius: 14

                        RowLayout {
                            id: timeRowLayout
                            anchors.centerIn: parent
                            spacing: 12

                            Tumbler {
                                id: hoursTumbler
                                model: 24
                                visibleItemCount: 3
                                height: 270 // Expanded to scale cleanly with 85px font
                                Layout.preferredWidth: 120
                                delegate: Text {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    font.pixelSize: hoursTumbler.currentIndex === index ?60 : 36
                                    font.bold: hoursTumbler.currentIndex === index
                                    opacity: hoursTumbler.currentIndex === index ? 1.0 : 0.2
                                    color: Atmosphere.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    height: 90 // Matches font allocation to prevent overlapping
                                }
                            }

                            Text { 
                                text: ":"
                                color: Atmosphere.textColor
                                font.pixelSize: 64 
                                opacity: 0.4
                                Layout.alignment: Qt.AlignVCenter
                                topPadding: -10 
                            }

                            Tumbler {
                                id: minutesTumbler
                                model: 60
                                visibleItemCount: 3
                                height: 270
                                Layout.preferredWidth: 120
                                delegate: Text {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    font.pixelSize: minutesTumbler.currentIndex === index ?60 : 36
                                    font.bold: minutesTumbler.currentIndex === index
                                    opacity: minutesTumbler.currentIndex === index ? 1.0 : 0.2
                                    color: Atmosphere.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    height: 90
                                }
                            }
                        }
                    }

                    // Divider Separation Line
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Atmosphere.secondaryAlphaColor
                        opacity: 0.15
                    }

                    // Date Dropdowns Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        ComboBox {
                            id: dayCombo
                            Layout.fillWidth: true
                            Layout.preferredWidth: .5
                            model: dateAndTimePage.daysModel
                        }

                        ComboBox {
                            id: monthCombo
                            Layout.fillWidth: true
                            Layout.preferredWidth: .5
                            model: dateAndTimePage.monthsModel
                        }

                        ComboBox {
                            id: yearCombo
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            model: dateAndTimePage.yearsModel
                        }
                    }
                }
            }

            // ── Actions Row Block (Directly above Set Automatically) ──────
            Item { width: 1; height: 14; visible: !automaticToggle.checked }
            RowLayout {
                width: parent.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14
                visible: !automaticToggle.checked 

                CutieButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1 
                    implicitHeight: commonHeight
                    text: qsTr("Reset")
                    onClicked: syncInputsToNow()
                }

                CutieButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1 
                    implicitHeight: commonHeight
                    text: qsTr("Apply Changes")

                    onClicked: {
                        var targetDate = new Date(
                            parseInt(yearCombo.currentText),
                            monthCombo.currentIndex,
                            parseInt(dayCombo.currentText),
                            hoursTumbler.currentIndex,
                            minutesTumbler.currentIndex,
                            0
                        )
                        console.log("Manual system time committed to:", targetDate.toString())
                    }
                }
            }

            Item { width: 1; height: 16 }

            // ── Card 2: Set Automatically ────────────────────────────────
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

            Item { width: 1; height: 16 }

            // ── Card 3: Time Zone Card ───────────────────────────────────
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
