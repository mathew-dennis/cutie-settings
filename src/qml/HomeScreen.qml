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

    function toggleVisibility() {
        let data = favoriteStore.data;
        data.visibility = !data.visibility;
        favoriteStore.data = data;
        console.log(" settingds app: Visibility toggled. Current state:", favoriteStore.data.visibility);

    }
}
