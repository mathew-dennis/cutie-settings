import Cutie
import QtQuick

CutieWindow {
	id: mainWindow
	width: 400
	height: 800
	visible: true
	title: qsTr("Settings")

	property var pages: [
		{
			text: qsTr("Wi-Fi"),
			icon: "network-wireless-symbolic",
			component: Qt.createComponent("Wifi.qml")
		},
		{
			text: qsTr("Mobile Network"),
			icon: "network-cellular-symbolic",
			component: Qt.createComponent("MobileNetwork.qml")
		},
		{
			text: qsTr("Audio"),
			icon: "audio-speakers-symbolic",
			component: Qt.createComponent("Audio.qml")
		},		
		{
			text: qsTr("Home Screen"),
			icon: "user-home-symbolic",
			component: Qt.createComponent("HomeScreen.qml")
		},
		{
			text: qsTr("About"),
			icon: "help-about-symbolic",
			component: Qt.createComponent("About.qml")
		}
	]

	initialPage: CutiePage {
		width: mainWindow.width
		height: mainWindow.height
		ListView {
			model: mainWindow.pages
			anchors.fill: parent
			header: CutiePageHeader {
				id: header
				title: mainWindow.title
			}

			delegate: CutieListItem {
				text: mainWindow.pages[index]["text"]
				icon.name: mainWindow.pages[index]["icon"]
				icon.color: Atmosphere.textColor

				onClicked: {
					if (mainWindow.pages[index]["component"].status === Component.Ready) {
						mainWindow.pageStack.push(
							mainWindow.pages[index]["component"]
							, {});
					}
				}
			}
		}	
	}

}
