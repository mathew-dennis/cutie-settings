import QtQuick
import Cutie
import Cutie.Battery

CutiePage {
	id: batteryPage

	Component.onCompleted: BatteryHistory.refresh()

	Flickable {
		anchors.fill: parent
		contentHeight: column.height

		Column {
			id: column
			width: parent.width

			CutiePageHeader {
				title: qsTr("Battery")
				width: parent.width
			}

			Canvas {
				id: graph
				width: parent.width - 40
				height: 200
				anchors.horizontalCenter: parent.horizontalCenter

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
	}
}
