// ── Reusable Theme Components ────────────────────────────────────────
    
    Component {
        id: themedDropdownDelegate
        ItemDelegate {
            id: delegateItem
            width: parent ? parent.width - 12 : 100
            height: 40
            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

            contentItem: CutieLabel {
                text: modelData
                color: delegateItem.highlighted ? Atmosphere.primaryColor : Atmosphere.textColor
                font.bold: delegateItem.highlighted
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                leftPadding: 8
            }

            background: Rectangle {
                color: delegateItem.highlighted ? secondaryAlphaLightColor : "transparent"
                radius: 8
            }
        }
    }

    Component {
        id: themedButtonBackground
        Rectangle {
            // We'll pass the focus state explicitly from the specific ComboBox now
            property bool isFocused: false 
            implicitHeight: commonHeight
            color: Atmosphere.secondaryColor 
            border.color: isFocused ? Atmosphere.primaryColor : Atmosphere.secondaryAlphaColor
            border.width: isFocused ? 2 : 1
            radius: 10
        }
    }

    Component {
        id: themedButtonContent
        CutieLabel {
            property string comboText: "" // We will feed the text directly from the ComboBox ID
            text: comboText
            font.pixelSize: 14
            color: Atmosphere.textColor
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            leftPadding: 12
            rightPadding: 30 
            elide: Text.ElideRight
        }
    }
