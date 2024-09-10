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

    CutieStore {
        id: favoriteStore
        appName: "cutie-launcher"
        storeName: "favoriteItems"
    }
}
