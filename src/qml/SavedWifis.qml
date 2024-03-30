import Cutie
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

CutiePage {
	ListView {
		model: CutieWifiSettings.savedConnections
		anchors.fill: parent
		spacing: 0

		header: ColumnLayout {
			width: parent.width
			CutiePageHeader {
				id: header
				title: qsTr("Saved Networks")
			}
		}

		delegate: CutieListItem {
			id: litem
			text: "connection" in modelData.data ? ("id" in modelData.data.connection ? modelData.data.connection.id: "") : ""
			highlighted: optionRow.visible
			subText: CutieWifiSettings.activeAccessPoint 
				&& "Ssid" in CutieWifiSettings.activeAccessPoint.data 
				&& "connection" in modelData.data ?
				(CutieWifiSettings.activeAccessPoint.data["Ssid"] == modelData.data.connection.id 
				? qsTr("Connected") :
				((CutieWifiSettings.accessPoints.filter(
				e => e.data["Ssid"] == modelData.data.connection.id)
				.length > 0) ? qsTr("Available") : qsTr("Unavailable"))) : ""
			icon.name: CutieWifiSettings.activeAccessPoint 
				&& "Ssid" in CutieWifiSettings.activeAccessPoint.data 
				&& "connection" in modelData.data &&
				(CutieWifiSettings.accessPoints.filter(
				e => e.data["Ssid"] == modelData.data.connection.id)
				.length > 0) ? ("network-wireless-signal-" +
				iconHelper.names[Math.floor((CutieWifiSettings.accessPoints.filter(
				e => e.data["Ssid"] == modelData.data.connection.id
				)[0].data["Strength"] - 1) / 20)]
				+ "-symbolic") 
				: "network-wireless-offline-symbolic"
			icon.color: Atmosphere.textColor
			onClicked: {
				menu.open();
			}
			menu: CutieMenu {
				id: optionRow
				CutieMenuItem {
					id: connectBtn
					text: qsTr("Connect")
					onTriggered: {
						CutieWifiSettings.activateConnection(modelData, null);
						CutieWifiSettings.requestScan();
					}
				}
				CutieMenuItem {
					id: forgetBtn
					text: qsTr("Forget")
					onTriggered: {
						modelData.deleteConnection();
						CutieWifiSettings.requestScan();
					}
				}
			}
		}
	}
}
