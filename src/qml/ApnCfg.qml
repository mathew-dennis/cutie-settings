import Cutie
import Cutie.Networking
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

CutiePage {
	id: apnPage
	property var apnData: null

	CutiePageHeader {
		id: header
		title: qsTr("Access Point Name")
		description: !apnData ? qsTr("Create a new access point") : qsTr("Edit access point")
	}

	ColumnLayout {
		anchors.top: header.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.margins: 20
		spacing: 15

		CutieLabel {
			text: qsTr("Name:")
			font.pixelSize: 12
		}
		CutieTextField {
			id: connName
			Layout.fillWidth: true
			text: !apnData ? "" : apnData.name;
		}

		CutieLabel {
			text: qsTr("APN:")
			font.pixelSize: 12
		}
		CutieTextField {
			id: connApn
			Layout.fillWidth: true
			text: !apnData ? "" : apnData.apn;
		}

		CutieButton {
			Layout.columnSpan: 2
			Layout.topMargin: 15
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignBottom
			text: !apnData ? qsTr("Create") : qsTr("Update")
			onClicked: {
				if(!apnData){
					CutieMobileNetwork.addAndActivateConnection(connName.displayText, connApn.displayText);
					mainWindow.pageStack.pop();
				} else {
					CutieMobileNetwork.updateConnection(apnData.path, connName.displayText, connApn.displayText);
					mainWindow.pageStack.pop();
				}
			}
		}
	}
}