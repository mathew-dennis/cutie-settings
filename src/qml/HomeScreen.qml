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
                    checked: favoriteStore.data["visibility"]

                    onToggled: {
                        toggleVisibility();
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

    Component.onCompleted: {
        if (!favoriteStore.data.hasOwnProperty("visibility")) {
            let data = favoriteStore.data;
            data.visibility = true;
            favoriteStore.data = data;
        }
    }

    function toggleVisibility() {
        let data = favoriteStore.data;
        data.visibility = !data.visibility;
        favoriteStore.data = data;
        console.log("settings app: Visibility toggled. Current state:", favoriteStore.data.visibility);
    }
}
