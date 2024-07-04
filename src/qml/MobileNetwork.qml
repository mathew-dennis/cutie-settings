import Cutie
import Cutie.Networking
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

CutiePage {
	id: mobileDataPage
	property var apnPage: Qt.createComponent("ApnCfg.qml")

	CutieListView {
		id: contextList
		model: CutieMobileNetwork.availableConnections
		anchors.fill: parent
		spacing: 0

		function updateActiveConnection() {
			if (CutieMobileNetwork.activeConnection === ""
				|| CutieMobileNetwork.activeConnection === "/") {
					contextList.currentIndex = -1;
				}
			else for (let i = 0; i < CutieMobileNetwork.availableConnections.length; i++) {
				if (CutieMobileNetwork.availableConnections[i].path
					== CutieMobileNetwork.activeConnection) {
						contextList.currentIndex = i;
					}
			}
		}

		Component.onCompleted: { updateActiveConnection(); }

		Connections {
			target: CutieMobileNetwork
			onActiveConnectionChanged: { contextList.updateActiveConnection(); }
		}

		header: ColumnLayout {
			width: parent.width
			CutiePageHeader {
				id: header
				title: qsTr("Mobile Network")
				width: parent.width

				CutieToggle {
					id: networkToggle
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					anchors.verticalCenterOffset: 5
					anchors.rightMargin: 15
					checked: CutieMobileNetwork.cellularEnabled

					onToggled: {
						CutieMobileNetwork.cellularEnabled = checked;
					}
				}
			}

			Item {
				id: mDataRow
				Layout.leftMargin: 20
				Layout.topMargin: 10
				Layout.bottomMargin: 3
				width: parent.width - 35
				height: dataToggle.height

				CutieLabel {
					text: qsTr("Mobile Data")
					horizontalAlignment: Text.AlignLeft
					topPadding: 10
					bottomPadding: 10
					anchors.left: parent.left
				}
				
				CutieToggle {
					id: dataToggle
					checked: CutieMobileNetwork.mobileDataEnabled
					enabled: CutieMobileNetwork.availableConnections.length > 0
					anchors.right: parent.right

					onToggled: {
						if (checked && contextList.currentIndex < 0
							&& CutieMobileNetwork.availableConnections.length > 0) {
							CutieMobileNetwork.activeConnection = 
								CutieMobileNetwork.availableConnections[0].path;
						} else CutieMobileNetwork.mobileDataEnabled = checked;
					}
				}
			}

			CutieLabel {
				text: qsTr("Access Point Names")
				horizontalAlignment: Text.AlignLeft
				Layout.leftMargin: 20
				Layout.topMargin: 10
				Layout.bottomMargin: 3
				width: parent.width - 35
				font.weight: Font.Bold
				font.pixelSize: 24
			}

			CutieLabel {
				text: qsTr("No APNs found.")
				horizontalAlignment: Text.AlignLeft
				Layout.leftMargin: 20
				Layout.topMargin: 10
				Layout.bottomMargin: 3
				width: parent.width - 35
				wrapMode: Text.WordWrap
				visible: CutieMobileNetwork.availableConnections.length < 1
			}
		}

		delegate: Item {
			height: litem.height
			width: parent ? parent.width : 0
			CutieListItem {
				id: litem
				text: modelData.name
				subText: modelData.apn
            	highlighted: contextList.currentIndex == index

				onClicked: {
					contextList.currentIndex = index;
					CutieMobileNetwork.activeConnection = modelData.path;
				}

				menu: CutieMenu {
					id: optionRow
					CutieMenuItem {
						id: editBtn
						text: qsTr("Edit")
						onTriggered: {
							mainWindow.pageStack.push(mobileDataPage.apnPage, {apnData: modelData});
						}
					}
					CutieMenuItem {
						id: deleteBtn
						text: qsTr("Remove")
						onTriggered: {
							CutieMobileNetwork.deleteConnection(modelData.path);
						}
					}
				}
			}
		}

		menu: CutieMenu {
			CutieMenuItem {
				text: qsTr("New APN")
				onTriggered: {
					mainWindow.pageStack.push(mobileDataPage.apnPage);
				}
			}
		}
	}
}