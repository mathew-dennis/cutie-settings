import Cutie
import Cutie.Networking
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

CutiePage {
	id: pskPage
	property var ap: null
	CutiePageHeader {
		id: header
		title: qsTr("Password")
		description: qsTr("Network \"%1\" requires authentication.").arg(ap.data["Ssid"])
	}
	CutieTextField {
		id: pskText
		text: ""
		anchors.top: header.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.margins: 20
		echoMode: TextInput.Password
	}
	CutieButton {
		id: connectbutton
		buttonText: qsTr("Connect")
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.margins: 20
		onClicked: {
			CutieWifiSettings.addAndActivateConnection(ap, pskText.text);
			mainWindow.pageStack.pop()
		}
	}
}