import Cutie
import QtCore
import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel

Rectangle {
    id: filePicker

    property url startFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
    property url selectedUrl: ""
    readonly property bool atRoot: folderModel.folder.toString() === "file:///"

    signal accepted(url fileUrl)
    signal cancelled()

    implicitWidth: 320
    implicitHeight: 430
    radius: 16
    color: Atmosphere.primaryColor
    border.color: Atmosphere.textColor
    border.width: 1

    onVisibleChanged: {
        if (visible)
            selectedUrl = ""
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius
        color: Atmosphere.secondaryAlphaColor
    }

    FolderListModel {
        id: folderModel
        folder: filePicker.startFolder
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.bmp"]
        caseSensitive: false
        showDirs: true
        showDirsFirst: true
        showDotAndDotDot: false
        showHidden: false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        CutieLabel {
            text: qsTr("Select wallpaper")
            font.pixelSize: 22
            font.weight: Font.Black
            Layout.fillWidth: true
        }

        // Current folder + up button
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            CutieButton {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                text: "↑"
                enabled: !filePicker.atRoot
                onClicked: {
                    filePicker.selectedUrl = ""
                    folderModel.folder = folderModel.parentFolder
                }
            }

            CutieLabel {
                Layout.fillWidth: true
                text: folderModel.folder.toString().replace("file://", "")
                elide: Text.ElideLeft
                font.pixelSize: 14
                opacity: 0.8
            }
        }

        // Folder / image list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            clip: true
            color: Qt.rgba(0, 0, 0, 0.15)
            border.color: Atmosphere.textColor
            border.width: 1

            ListView {
                id: fileList
                anchors.fill: parent
                anchors.margins: 1
                model: folderModel
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: row
                    required property string fileName
                    required property url fileUrl
                    required property bool fileIsDir
                    readonly property bool isSelected: !fileIsDir && fileUrl === filePicker.selectedUrl

                    width: fileList.width
                    height: 56
                    color: isSelected ? Atmosphere.secondaryAlphaColor : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        Item {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40

                            // Folder glyph
                            Item {
                                anchors.fill: parent
                                visible: row.fileIsDir

                                Rectangle {
                                    x: 5
                                    y: 9
                                    width: 14
                                    height: 8
                                    radius: 3
                                    color: "transparent"
                                    border.color: Atmosphere.textColor
                                    border.width: 1
                                }
                                Rectangle {
                                    x: 5
                                    y: 13
                                    width: 30
                                    height: 20
                                    radius: 4
                                    color: Atmosphere.primaryColor
                                    border.color: Atmosphere.textColor
                                    border.width: 1
                                }
                            }

                            // Image thumbnail (decoded small to keep memory low)
                            Image {
                                anchors.fill: parent
                                visible: !row.fileIsDir
                                source: row.fileIsDir ? "" : row.fileUrl
                                sourceSize: Qt.size(80, 80)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: false
                            }
                        }

                        CutieLabel {
                            Layout.fillWidth: true
                            text: row.fileName
                            elide: Text.ElideMiddle
                            font.pixelSize: 16
                        }

                        CutieLabel {
                            visible: row.fileIsDir
                            text: "›"
                            font.pixelSize: 22
                            opacity: 0.6
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (row.fileIsDir) {
                                filePicker.selectedUrl = ""
                                folderModel.folder = row.fileUrl
                            } else {
                                filePicker.selectedUrl = row.fileUrl
                            }
                        }
                    }
                }
            }

            CutieLabel {
                anchors.centerIn: parent
                visible: fileList.count === 0
                text: qsTr("No images here")
                opacity: 0.6
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            CutieButton {
                Layout.fillWidth: true
                text: qsTr("Back")
                onClicked: filePicker.cancelled()
            }
            CutieButton {
                Layout.fillWidth: true
                text: qsTr("Done")
                enabled: filePicker.selectedUrl != ""
                onClicked: filePicker.accepted(filePicker.selectedUrl)
            }
        }
    }
}
