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

			// â”€â”€ Current state card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

			// â”€â”€ History card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
					text: qsTr("Collecting battery historyâ€¦")
					opacity: 0.6
				}

				Canvas {
					id: graph
					visible: BatteryHistory.points.length >= 2
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.top: parent.top
					anchors.margins: 20
					height: 180

					readonly property int leftAxis: 34
					readonly property int bottomAxis: 18

					onPaint: {
						var ctx = getContext("2d");
						ctx.reset();
						var pts = BatteryHistory.points;
						if (pts.length < 2)
							return;

						var plotX = leftAxis;
						var plotW = width - leftAxis;
						var plotH = height - bottomAxis;

						ctx.font = "11px sans-serif";
						ctx.fillStyle = Atmosphere.textColor;
						ctx.strokeStyle = Qt.rgba(Atmosphere.textColor.r, Atmosphere.textColor.g, Atmosphere.textColor.b, 0.15);
						ctx.lineWidth = 1;

						// Y axis: 0/50/100%
						[0, 50, 100].forEach(function (pct) {
							var y = plotH - (pct / 100) * plotH;
							ctx.beginPath();
							ctx.moveTo(plotX, y);
							ctx.lineTo(width, y);
							ctx.stroke();
							ctx.fillText(pct + "%", 0, y + 4);
						});

						// X axis: first/middle/last timestamps
						var mid = Math.floor(pts.length / 2);
						[0, mid, pts.length - 1].forEach(function (i) {
							var label = Qt.formatDateTime(new Date(pts[i].time * 1000), "hh:mm");
							var x = plotX + (i / (pts.length - 1)) * plotW;
							ctx.fillText(label, Math.min(Math.max(x - 14, plotX), width - 30), height);
						});

						// The line itself
						ctx.strokeStyle = Atmosphere.textColor;
						ctx.lineWidth = 2;
						ctx.beginPath();
						for (var i = 0; i < pts.length; i++) {
							var x = plotX + (i / (pts.length - 1)) * plotW;
							var y = plotH - (pts[i].value / 100) * plotH;
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
