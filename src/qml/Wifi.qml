import Cutie
import QtQuick
import QtQuick.Layouts

CutiePage {
	id: page
	property var pskPage: Qt.createComponent("WifiPsk.qml")
	property var savedPage: Qt.createComponent("SavedWifis.qml")

	QtObject {
		id: iconHelper
		property var names: ["none", "weak", "ok", "good", "excellent"]
	}

	CutieListView {
		model: CutieWifiSettings.accessPoints
		anchors.fill: parent
		spacing: 0

		Component.onCompleted: {
			CutieWifiSettings.requestScan();
		}

		header: ColumnLayout {
			width: parent.width
			CutiePageHeader {
				id: header
				title: qsTr("Wi-Fi")
				width: parent.width

				CutieToggle {
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					anchors.verticalCenterOffset: 5
					anchors.rightMargin: 15
					checked: CutieWifiSettings.wirelessEnabled

					onToggled: {
						CutieWifiSettings.wirelessEnabled = checked;
					}
				}
			}
			CutieLabel {
				visible: CutieWifiSettings.activeAccessPoint
				text: qsTr("Connected")
				horizontalAlignment: Text.AlignLeft
				Layout.leftMargin: 20
				Layout.rightMargin: 20
				Layout.topMargin: 10
				Layout.bottomMargin: 3
			}
			CutieListItem {
				Layout.fillWidth: true
				visible: CutieWifiSettings.activeAccessPoint
				icon.name: visible ? ("network-wireless-signal-" +
					iconHelper.names[Math.floor((CutieWifiSettings.activeAccessPoint.data["Strength"] - 1) / 20)]
				+ "-symbolic") : ""
				icon.color: Atmosphere.textColor
				text: visible ? CutieWifiSettings.activeAccessPoint.data["Ssid"] : ""
				subText: visible ? ((CutieWifiSettings.activeAccessPoint.data["Frequency"] > 4 ? "5GHz " : "2.4GHz ") 
					+ ((CutieWifiSettings.activeAccessPoint.data["Flags"] & 0x1) == 0 ? "Open" : 
					((CutieWifiSettings.activeAccessPoint.data["RsnFlags"] & 0x100) > 0 ? "WPA2-PSK" :
					(CutieWifiSettings.activeAccessPoint.data["WpaFlags"] & 0x100) > 0 ? "WPA1-PSK" : 
					"Unknown Security"))) : ""
			}
			CutieLabel {
				visible: CutieWifiSettings.wirelessEnabled
				text: qsTr("Available")
				horizontalAlignment: Text.AlignLeft
				Layout.leftMargin: 20
				Layout.rightMargin: 20
				Layout.topMargin: 10
				Layout.bottomMargin: 3
			}
		}

		delegate: Item {
			visible: CutieWifiSettings.activeAccessPoint ? (modelData.path != CutieWifiSettings.activeAccessPoint.path &&
				litem.text != "") : true
			height: visible ? litem.height : 0
			width: parent ? parent.width : 0
			CutieListItem {
				id: litem
				icon.name: ("network-wireless-signal-" +
					iconHelper.names[Math.floor((modelData.data["Strength"] - 1) / 20)]
				+ "-symbolic")
				icon.color: Atmosphere.textColor
				text: modelData.data["Ssid"]
				subText: ((modelData.data["Frequency"] > 4000 ? "5GHz " : "2.4GHz ") 
					+ ((modelData.data["Flags"] & 0x1) == 0 ? "Open" : 
					((modelData.data["RsnFlags"] & 0x100) > 0 ? "WPA2-PSK" :
					(modelData.data["WpaFlags"] & 0x100) > 0 ? "WPA1-PSK" : 
					"Unknown Security")))
				onClicked: {
					var conn = CutieWifiSettings.savedConnections.filter(
						e => e.data["connection"]["id"] == modelData.data["Ssid"])[0];
					if (conn)
						CutieWifiSettings.activateConnection(conn, modelData);
					else if ((modelData.data["Flags"] & 0x1) == 1) {
						if (page.pskPage.status === Component.Ready) {
							mainWindow.pageStack.push(page.pskPage, {ap: modelData});
						}
					} else {
						CutieWifiSettings.addAndActivateConnection(modelData, "");
					}
					CutieWifiSettings.requestScan();
				}
			}
		}

		menu: CutieMenu {
			CutieMenuItem {
				text: qsTr("Saved Networks")
				onTriggered: {
					if (page.savedPage.status === Component.Ready) {
						mainWindow.pageStack.push(page.savedPage, {});
					}
				}
			}
			CutieMenuItem {
				text: qsTr("Refresh")
				onTriggered: {
					CutieWifiSettings.requestScan();
				}
			}
		}
	}

	CutieLabel {
		visible: !CutieWifiSettings.wirelessEnabled
		text: qsTr("Wi-Fi is disabled")
		anchors.centerIn: parent
		anchors.margins: 20
		font.pixelSize: 24
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		elide: Text.ElideRight
	}
}
