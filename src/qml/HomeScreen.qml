import Cutie
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Cutie.Store

CutiePage {
    id: homeScreenPage
    Flickable {
        anchors.fill: parent
        Column {
            width: parent.width
            CutiePageHeader {
                id: header
                title: qsTr("Home Screen")
                width: parent.width

			Item {
				id: showFavouritsText
				Layout.leftMargin: 20
				Layout.topMargin: 10
				Layout.bottomMargin: 3
				width: parent.width - 35
				height: dataToggle.height

				CutieLabel {
					text: qsTr("Favorites Dock")
					horizontalAlignment: Text.AlignLeft
					topPadding: 10
					bottomPadding: 10
					anchors.left: parent.left
				}

                CutieToggle {
                    id: visibilityToggle
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 5
                    anchors.rightMargin: 15
                    checked: "visibility" in favoriteStore.data ? favoriteStore.data["visibility"] : true

                    onToggled: {
                        let data = favoriteStore.data;
                        data.visibility = visibilityToggle.checked;
                        favoriteStore.data = data;
                        console.log("Settings app: Visibility toggled. Current state:", favoriteStore.data.visibility);

                    }
                }

			}

            }
        }
    }

    CutieStore {
        id: favoriteStore
        appName: "cutie-launcher"
        storeName: "favoriteItems"
    }
}
