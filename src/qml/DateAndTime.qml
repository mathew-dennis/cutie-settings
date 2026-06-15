import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Store

CutiePage {
    id: dateAndTimePage

    // ── Inline Reusable Component (Qt 5.15+) ─────────────────────────────
    component CutieDropdownList: ComboBox {
        id: control

        // 1. Increased Selection Button Text
        contentItem: CutieLabel {
            text: control.currentText
            font.pixelSize: 14 // Increased for better readability
            color: Atmosphere.textColor
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            leftPadding: 10
            rightPadding: 20
            elide: Text.ElideRight
        }

        // 2. Increased Selection Button Background (30px = 20px * 1.5)
        background: Rectangle {
            implicitHeight: 30 
            color: Atmosphere.secondaryColor 
            border.color: control.visualFocus ? Atmosphere.primaryColor : Atmosphere.secondaryAlphaColor
            border.width: control.visualFocus ? 2 : 1
            radius: 6 // Slightly larger radius
        }

        // 3. Increased Dropdown List Items
        delegate: ItemDelegate {
            id: delegateItem
            width: parent ? parent.width - 6 : 100
            height: 30 // Matches the 30px height
            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

            contentItem: CutieLabel {
                text: modelData
                color: delegateItem.highlighted ? Atmosphere.primaryColor : Atmosphere.textColor
                font.bold: delegateItem.highlighted
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                leftPadding: 10
            }

            background: Rectangle {
                color: delegateItem.highlighted ? Qt.rgba(Atmosphere.secondaryAlphaColor.r, Atmosphere.secondaryAlphaColor.g, Atmosphere.secondaryAlphaColor.b, 0.1) : "transparent"
                radius: 6
            }
        }

        // 4. Dropdown Menu Window
        popup: Popup {
            y: control.height + 4
            width: control.width
            implicitHeight: Math.min(contentItem.implicitHeight + 12, 250)
            padding: 6
            
            background: Rectangle {
                color: Atmosphere.secondaryColor
                border.color: Atmosphere.secondaryAlphaColor
                border.width: 1
                radius: 8
            }
            
            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: control.popup.visible ? control.delegateModel : null
                currentIndex: control.highlightedIndex
                ScrollIndicator.vertical: ScrollIndicator { }
            }
        }
    }
    // ─────────────────────────────────────────────────────────────────────

    // ── Design System Constants ──────────────────────────────────────────
    readonly property color secondaryAlphaLightColor: Qt.rgba (
        Atmosphere.secondaryAlphaColor.r,
        Atmosphere.secondaryAlphaColor.g,
        Atmosphere.secondaryAlphaColor.b,
        0.1
    )
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
                    Layout.fillWidth: true
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
                        implicitWidth: timeRowLayout.implicitWidth + cardPadding * 2
                        implicitHeight: timeRowLayout.implicitHeight +  cardPadding * 2
                        color:  "transparent"
                        border.color: Atmosphere.primaryColor
                        border.width: 2
                        radius: 14

                        RowLayout {
                            id: timeRowLayout
                            anchors.centerIn: parent
                            spacing: 12

                            Tumbler {
                                id: hoursTumbler
                                model: 24
                                visibleItemCount: 3
                                height: 270 
                                Layout.preferredWidth: 100
                                delegate: Text {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    font.pixelSize: hoursTumbler.currentIndex === index ? 60 : 36
                                    font.bold: hoursTumbler.currentIndex === index
                                    opacity: hoursTumbler.currentIndex === index ? 1.0 : 0.2
                                    color: Atmosphere.textColor
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    height: 90 
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
                                Layout.preferredWidth: 100
                                delegate: Text {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    font.pixelSize: minutesTumbler.currentIndex === index ? 60 : 36
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

                    // Date Dropdowns Row using Inline Component
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        CutieDropdownList {
                            id: dayCombo
                            Layout.fillWidth: true
                            Layout.preferredWidth: .5
                            model: dateAndTimePage.daysModel
                        }

                        CutieDropdownList {
                            id: monthCombo
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            model: dateAndTimePage.monthsModel
                        }

                        CutieDropdownList {
                            id: yearCombo
                            Layout.fillWidth: true
                            Layout.preferredWidth: .5
                            model: dateAndTimePage.yearsModel
                        }
                    }
                }
            }

            // ── Actions Row Block ─────────────────────────────────────────
            Item { width: 1; height: 14; visible: !automaticToggle.checked }
            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14
                visible: !automaticToggle.checked 

                CutieButton {
                    text: qsTr("Reset")
                    onClicked: syncInputsToNow()
                }

                CutieButton {
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

                    CutieDropdownList {
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
