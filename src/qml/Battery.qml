import QtQuick
import Cutie
import Cutie.Battery

CutiePage {
	id: batteryPage

	readonly property color cardColor: Qt.alpha(Atmosphere.secondaryAlphaColor, 0.1)
	readonly property color fillColor: BatteryHistory.percentage <= 20 ? "#E57373" : "#A5D6A7"
	readonly property bool charging: BatteryHistory.stateString === "Charging"

	function formatDuration(seconds) {
		if (seconds <= 0)
			return qsTr("—")
		var h = Math.floor(seconds / 3600)
		var m = Math.floor((seconds % 3600) / 60)
		return h > 0 ? qsTr("%1h %2m").arg(h).arg(m) : qsTr("%1m").arg(m)
	}

	// UPower derives timeToEmpty/timeToFull from Energy/EnergyRate. When
	// energyRate is near zero (device hasn't settled on a rate yet, or
	// the HAL just isn't reporting one) that division produces a huge,
	// meaningless duration rather than an error - so below a small
	// threshold, show that it's unreliable instead of a bogus number.
	function timeRemainingText() {
		if (Math.abs(BatteryHistory.energyRate) < 0.05)
			return qsTr("N/A")
		return batteryPage.charging
			? formatDuration(BatteryHistory.timeToFull)
			: formatDuration(BatteryHistory.timeToEmpty)
	}

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
			// Filled left-to-right by charge level: light green, red
			// once at/below 20%.
			Rectangle {
				width: parent.width - 32
				anchors.horizontalCenter: parent.horizontalCenter
				height: statsRow.implicitHeight + 40
				color: batteryPage.cardColor
				radius: 16
				clip: true

				Rectangle {
					width: parent.width * (BatteryHistory.percentage / 100)
					height: parent.height
					color: batteryPage.fillColor
					opacity: 0.35
					radius: 16

					Behavior on width {
						NumberAnimation { duration: 400; easing.type: Easing.OutQuad }
					}
					Behavior on color {
						ColorAnimation { duration: 400 }
					}
				}

				Row {
					id: statsRow
					anchors.centerIn: parent
					width: parent.width - 40
					spacing: 20

					// Left: time remaining
					Column {
						width: (parent.width - parent.spacing) / 2
						spacing: 4

						CutieLabel {
							width: parent.width
							text: batteryPage.timeRemainingText()
							font.pixelSize: 30
							font.bold: true
							wrapMode: Text.WordWrap
						}
						CutieLabel {
							width: parent.width
							text: batteryPage.charging ? qsTr("Time to full charge") : qsTr("Time to empty")
							font.pixelSize: 12
							opacity: 0.7
							wrapMode: Text.WordWrap
						}
					}

					// Right: power draw / capacity
					Column {
						width: (parent.width - parent.spacing) / 2
						spacing: 4

						CutieLabel {
							width: parent.width
							text: qsTr("%1 W").arg(BatteryHistory.energyRate.toFixed(1))
							font.pixelSize: 30
							font.bold: true
							wrapMode: Text.WordWrap
						}
						CutieLabel {
							width: parent.width
							text: qsTr("%1% capacity").arg(Math.round(BatteryHistory.capacity))
							font.pixelSize: 12
							opacity: 0.7
							wrapMode: Text.WordWrap
						}
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
					height: 180

					// Extra padding on the left ensures the graph starts AFTER scale numbers
					readonly property int leftAxis: 45
					readonly property int bottomAxis: 24

					onWidthChanged: requestPaint()
					onHeightChanged: requestPaint()

					onPaint: {
						var ctx = getContext("2d");
						ctx.reset();

						// Sort points chronologically: oldest first (left), newest last (right)
						var pts = BatteryHistory.points.slice().sort(function(a, b) {
							return a.time - b.time;
						});

						if (pts.length < 2)
							return;

						var plotX = leftAxis;
						var plotW = width - leftAxis;
						var plotH = height - bottomAxis;

						ctx.font = "11px sans-serif";
						ctx.fillStyle = Atmosphere.textColor;
						ctx.strokeStyle = Qt.alpha(Atmosphere.textColor, 0.15);
						ctx.lineWidth = 1;

						// Y axis: linear grid lines 0/25/50/75/100%.
						[0, 25, 50, 75, 100].forEach(function (pct) {
							var y = plotH - (pct / 100) * plotH;
							ctx.beginPath();
							ctx.moveTo(plotX, y);
							ctx.lineTo(width, y);
							ctx.stroke();
							// Labels render to the left of plotX
							ctx.fillText(pct + "%", 0, Math.min(Math.max(y + 4, 10), plotH));
						});

						// X axis mapping: oldest at plotX, newest at plotX + plotW
						var oldestTime = pts[0].time;
						var newestTime = pts[pts.length - 1].time;
						var span = Math.max(1, newestTime - oldestTime);

						function xForTime(t) {
							if (pts.length === 2)
								return t === oldestTime ? plotX : plotX + plotW;
							return plotX + ((t - oldestTime) / span) * plotW;
						}

						// X axis labels (first, middle, last)
						var mid = Math.floor(pts.length / 2);
						var labelIdxs = [...new Set([0, mid, pts.length - 1])];
						labelIdxs.forEach(function (i) {
							var label = Qt.formatDateTime(new Date(pts[i].time * 1000), "hh:mm");
							var x = xForTime(pts[i].time);
							var labelWidth = ctx.measureText(label).width;
							
							// Center the text under its data point, clamped within the graph boundaries
							var labelX = Math.min(Math.max(x - labelWidth / 2, plotX), width - labelWidth);
							ctx.fillText(label, labelX, height - 2);
						});

						// Plot graph line
						ctx.strokeStyle = Atmosphere.textColor;
						ctx.lineWidth = 2;
						ctx.lineJoin = "round";
						ctx.beginPath();
						for (var i = 0; i < pts.length; i++) {
							var x = xForTime(pts[i].time);
							var y = plotH - (pts[i].value / 100) * plotH;
							if (i === 0) 
								ctx.moveTo(x, y); 
							else 
								ctx.lineTo(x, y);
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
