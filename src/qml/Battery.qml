import QtQuick
import Cutie
import Cutie.Battery

CutiePage {
	id: batteryPage

	readonly property color cardColor: Qt.rgba(
		Atmosphere.secondaryAlphaColor.r,
		Atmosphere.secondaryAlphaColor.g,
		Atmosphere.secondaryAlphaColor.b,
		0.1
	)

	Component.onCompleted: BatteryHistory.refresh()

	Flickable {
		anchors.fill: parent
		contentHeight: column.height

		Column {
			id: column
			width: parent.width
			spacing: 16

			CutiePageHeader {
				title: qsTr("Battery")
				width: parent.width
			}

			// ── Current state card ───────────────────────────────────
			Rectangle {
				width: parent.width - 32
				anchors.horizontalCenter: parent.horizontalCenter
				height: stateColumn.implicitHeight + 40
				color: batteryPage.cardColor
				radius: 16

				Column {
					id: stateColumn
					anchors.centerIn: parent
					spacing: 4

					CutieLabel {
						anchors.horizontalCenter: parent.horizontalCenter
						text: Math.round(BatteryHistory.percentage) + "%"
						font.pixelSize: 40
						font.bold: true
					}
					CutieLabel {
						anchors.horizontalCenter: parent.horizontalCenter
						text: BatteryHistory.stateString
						opacity: 0.7
					}
				}
			}

			// ── History card ─────────────────────────────────────────
			// Shows the graph once UPower has enough persisted history;
			// otherwise a plain message rather than an empty-looking box.
			Rectangle {
				width: parent.width - 32
				anchors.horizontalCenter: parent.horizontalCenter
				height: (BatteryHistory.points.length >= 2 ? graph.height : historyLabel.implicitHeight) + 40
				color: batteryPage.cardColor
				radius: 16

				CutieLabel {
					id: historyLabel
					anchors.centerIn: parent
					visible: BatteryHistory.points.length < 2
					text: qsTr("Collecting battery history…")
					opacity: 0.6
				}

				Canvas {
					id: graph
					visible: BatteryHistory.points.length >= 2
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.top: parent.top
					anchors.margins: 20
					height: 160

					onPaint: {
						var ctx = getContext("2d");
						ctx.reset();
						var pts = BatteryHistory.points;
						if (pts.length < 2)
							return;

						var stepX = width / (pts.length - 1);
						ctx.strokeStyle = Atmosphere.textColor;
						ctx.lineWidth = 2;
						ctx.beginPath();
						for (var i = 0; i < pts.length; i++) {
							var x = i * stepX;
							var y = height - (pts[i].value / 100) * height;
							if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
						}
						ctx.stroke();
					}

					Connections {
						target: BatteryHistory
						function onPointsChanged() { graph.requestPaint(); }
					}
				}
			}

			Item { width: 1; height: 16 }
		}
	}
}