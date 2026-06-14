import QtQuick
import QtQuick.Controls
import Cutie 

CutiePage {
    id: dateAndTimesettingsPage
    title: qsTr("Time And Date")

    // If your PageStack relies on a specific layout behavior, 
    // wrapping your content inside an Item or Column prevents layout breaking.
    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 20

        Text {
            text: qsTr("Date & Time Settings")
            font.pixelSize: 20
            color: Atmosphere.textColor
        }

        // Placeholder to verify the page works
        Text {
            text: qsTr("Component loaded successfully.")
            font.pixelSize: 14
            color: Atmosphere.textColor
            opacity: 0.7
        }
    }
}
