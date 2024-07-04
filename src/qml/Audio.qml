import Cutie
import Cutie.Volume
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

CutiePage {
	id: audioPage
	Flickable {
		anchors.fill: parent
		Column {
			width: parent.width
			CutiePageHeader {
				id: header
				title: qsTr("Audio")
				width: parent.width

				CutieToggle {
					id: muteToggle
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					anchors.verticalCenterOffset: 5
					anchors.rightMargin: 15
					checked: !CutieVolume.muted

					onToggled: {
						CutieVolume.muted = !checked;
					}
					Connections {
						target: CutieVolume
						function onMutedChanged(m) {
							muteToggle.checked = !m;
						}
					}
				}
			}

			CutieLabel {
				text: qsTr("Master volume")
				horizontalAlignment: Text.AlignLeft
				leftPadding: 20
				rightPadding: 20
				topPadding: 10
				bottomPadding: 10
			}

			CutieSlider {
				id: volSlider
				value: CutieVolume.volume
				x: 20
				width: parent.width - 40
				onMoved: {
					CutieVolume.volume = value;
				}
				Connections {
					target: CutieVolume
					function onVolumeChanged(vol) {
						volSlider.value = vol;
					}
				}
			}
		}
	}
}