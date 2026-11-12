import Cutie
import Cutie.Networking
import QtQuick
import QtQuick.Layouts

CutiePage {
	id: page
	property var pskPage: Qt.createComponent("WifiPsk.qml")
	property var savedPage: Qt.createComponent("SavedWifis.qml")

	QtObject {
		id: wifiHelper
		property var signalNames: ["none", "weak", "ok", "good", "excellent"]

		function getSignalIcon(strength) {
			var index = Math.floor((strength - 1) / 20);
			index = Math.max(0, Math.min(index, signalNames.length - 1));
			return "network-wireless-signal-" + signalNames[index] + "-symbolic";
		}

		function getFrequencyString(freq) {
			return (freq > 4000) ? "5GHz " : "2.4GHz ";
		}

		function getSecurityString(flags, rsnFlags, wpaFlags) {
			if ((flags & 0x1) === 0) return "Open";
			if ((rsnFlags & 0x100) > 0) return "WPA2-PSK";
			if ((wpaFlags & 0x100) > 0) return "WPA1-PSK";
			return "Unknown Security";
		}
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

				// Wrapped inside a layout-safe item to prevent transition disappearance
				CutieToggle {
					id: wifiToggle
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					anchors.verticalCenterOffset: 5
					anchors.rightMargin: 15
					// Ensure width/height bindings evaluate reliably during page transitions
					visible: parent && parent.width > 0
					checked: CutieWifiSettings.wirelessEnabled

					onToggled: {
						CutieWifiSettings.wirelessEnabled = checked;
					}
				}
			}

			// Active Connection Section
			CutieLabel {
				visible: CutieWifiSettings.activeAccessPoint !== null
				text: qsTr("Connected")
				horizontalAlignment: Text.AlignLeft
				Layout.leftMargin: 20
				Layout.rightMargin: 20
				Layout.topMargin: 10
				Layout.bottomMargin: 3
			}

			CutieListItem {
				Layout.fillWidth: true
				visible: CutieWifiSettings.activeAccessPoint !== null
				icon.name: visible ? wifiHelper.getSignalIcon(CutieWifiSettings.activeAccessPoint.data["Strength"]) : ""
				icon.color: Atmosphere.textColor
				text: visible ? CutieWifiSettings.activeAccessPoint.data["Ssid"] : ""
				subText: visible ? (wifiHelper.getFrequencyString(CutieWifiSettings.activeAccessPoint.data["Frequency"]) +
					wifiHelper.getSecurityString(
						CutieWifiSettings.activeAccessPoint.data["Flags"],
						CutieWifiSettings.activeAccessPoint.data["RsnFlags"],
						CutieWifiSettings.activeAccessPoint.data["WpaFlags"]
					)) : ""
			}

			// Available Networks Header
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
			readonly property var apData: modelData.data || {}
			readonly property bool isActive: CutieWifiSettings.activeAccessPoint && modelData.path === CutieWifiSettings.activeAccessPoint.path
			
			visible: !isActive && apData["Ssid"] !== ""
			height: visible ? litem.height : 0
			width: parent ? parent.width : 0

			CutieListItem {
				id: litem
				icon.name: wifiHelper.getSignalIcon(apData["Strength"] || 0)
				icon.color: Atmosphere.textColor
				text: apData["Ssid"] || ""
				subText: wifiHelper.getFrequencyString(apData["Frequency"] || 0) +
					wifiHelper.getSecurityString(apData["Flags"] || 0, apData["RsnFlags"] || 0, apData["WpaFlags"] || 0)

				onClicked: {
					var savedConns = CutieWifiSettings.savedConnections || [];
					var conn = savedConns.filter(e => e.data["connection"]["id"] === apData["Ssid"])[0];

					if (conn) {
						CutieWifiSettings.activateConnection(conn, modelData);
					} else if ((apData["Flags"] & 0x1) === 1) {
						if (page.pskPage.status === Component.Ready) {
							mainWindow.pageStack.push(page.pskPage, { ap: modelData });
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
```[cite: 1]
