import Cutie
import Cutie.ScreenLock
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

CutiePage {
	id: lockScreenPage

	CutieScreenLock {
		id: lockAuthClient
	}

	readonly property var methods: [
		{ key: "none", label: qsTr("None"), description: qsTr("No lock screen protection.") },
		{ key: "pin", label: qsTr("PIN"), description: qsTr("Unlock with a numeric code.") },
		{ key: "pattern", label: qsTr("Pattern"), description: qsTr("Unlock by drawing a pattern.") },
		{ key: "password", label: qsTr("Password"), description: qsTr("Unlock with your device password.") }
	]

	function selectMethod(targetKey) {
		if (targetKey === lockAuthClient.method)
			return;
		mainWindow.pageStack.push(
			Qt.resolvedUrl("LockScreenAuth.qml"),
			{ currentMethod: lockAuthClient.method, targetMethod: targetKey }
		);
	}

	CutiePageHeader {
		id: header
		title: qsTr("Lock Screen")
		description: lockAuthClient.available
					 ? qsTr("Choose how to unlock your device.")
					 : qsTr("Cutie Panel isn't running - can't reach the lock screen service.")
		width: parent.width
	}

	Column {
		anchors.top: header.bottom
		anchors.topMargin: 16
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.margins: 20
		spacing: 12

		Repeater {
			model: lockScreenPage.methods

			Rectangle {
				width: parent.width
				height: rowLayout.implicitHeight + 28
				radius: 12
				color: Atmosphere.secondaryAlphaColor
				border.width: lockAuthClient.method === modelData.key ? 2 : 0
				border.color: Atmosphere.primaryColor

				RowLayout {
					id: rowLayout
					anchors.fill: parent
					anchors.margins: 14
					spacing: 12

					ColumnLayout {
						Layout.fillWidth: true
						spacing: 2

						CutieLabel {
							text: modelData.label
							font.bold: true
							font.pixelSize: 15
						}

						CutieLabel {
							text: modelData.description
							font.pixelSize: 12
							opacity: 0.7
							wrapMode: Text.WordWrap
							Layout.fillWidth: true
						}
					}

					CutieLabel {
						text: "\u2713"
						color: Atmosphere.primaryColor
						visible: lockAuthClient.method === modelData.key
						font.pixelSize: 18
					}
				}

				MouseArea {
					anchors.fill: parent
					enabled: lockAuthClient.available
					onClicked: lockScreenPage.selectMethod(modelData.key)
				}
			}
		}

		Item { width: 1; height: 4 }

		CutieLabel {
			text: qsTr("Note: switching away from a PIN or pattern will ask you to confirm the current one first.")
			font.pixelSize: 11
			opacity: 0.6
			width: parent.width
			wrapMode: Text.WordWrap
		}
	}
}