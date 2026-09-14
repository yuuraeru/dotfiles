import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Config
import qs.Services

Item {
    id: root

    implicitWidth: 1280
    implicitHeight: 340

    visible: LauncherService.mode === "WallpaperManager"

    onVisibleChanged: {
        if (!visible)
            return;

        WallpaperService.reset();
        WallpaperService.refresh();
        textInput.forceActiveFocus();
    }

    Connections {
        target: WallpaperService

        function onSelectedIndexChanged() {
            wallpaperList.positionViewAtIndex(WallpaperService.selectedIndex, ListView.Contain);
        }
    }

    Rectangle {
        id: container
        anchors.fill: parent

        radius: Config.rounding
        color: Colors.base

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            spacing: 10

            Rectangle {
                color: Colors.crust
                radius: height / 2

                Layout.fillWidth: true
                Layout.preferredHeight: 40

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    Text {
                        text: ""
                        color: Colors.lavender

                        font {
                            family: Fonts.icon
                            pixelSize: Fonts.iconNormal
                        }

                        Layout.alignment: Qt.AlignVCenter
                    }

                    TextInput {
                        id: textInput

                        color: Colors.text

                        font {
                            family: Fonts.normal
                            pixelSize: Fonts.textNormal
                        }

                        Layout.fillWidth: true
                        Layout.preferredHeight: 32

                        verticalAlignment: Text.AlignVCenter
                        clip: true

                        text: LauncherService.query

                        onTextChanged: {
                            if (LauncherService.query !== text)
                                LauncherService.query = text;
                        }

                        Text {
                            anchors.fill: parent

                            text: "Search wallpapers..."

                            color: Colors.overlay0
                            font: parent.font

                            verticalAlignment: Text.AlignVCenter

                            visible: textInput.text.length === 0
                        }

                        Keys.onPressed: e => {
                            if (e.key === Qt.Key_Tab && e.modifiers & Qt.ControlModifier) {
                                LauncherService.cycle(1);
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Backtab && e.modifiers & Qt.ControlModifier) {
                                LauncherService.cycle(-1);
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Right || (e.key === Qt.Key_Tab && !(e.modifiers & Qt.ControlModifier))) {
                                WallpaperService.navigate(1);
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Left || (e.key === Qt.Key_Backtab && !(e.modifiers & Qt.ControlModifier))) {
                                WallpaperService.navigate(-1);
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                if (WallpaperService.filteredWallpapers.length > 0) {
                                    WallpaperService.setWallpaper(WallpaperService.filteredWallpapers[WallpaperService.selectedIndex]);

                                    LauncherService.hide();
                                }

                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_F2) {
                                const count = WallpaperService.filteredWallpapers.length;

                                if (count > 0) {
                                    WallpaperService.selectedIndex = Math.floor(Math.random() * count);
                                    e.accepted = true;
                                }
                            }

                            if (e.key === Qt.Key_Escape) {
                                LauncherService.hide();
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_W && e.modifiers & Qt.ControlModifier) {
                                textInput.clear();
                                e.accepted = true;
                                return;
                            }
                        }
                    }
                }
            }

            ListView {
                id: wallpaperList

                model: WallpaperService.filteredWallpapers

                orientation: ListView.Horizontal

                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 10
                clip: true

                delegate: Rectangle {
                    id: entry

                    required property string modelData
                    required property int index

                    width: 480
                    height: 270

                    radius: Config.rounding

                    border.width: 5
                    border.color: mouseArea.containsMouse ? Colors.lavender : WallpaperService.currentWallpaper === WallpaperService.wallpaperDir + "/" + entry.modelData ? Colors.green : index === WallpaperService.selectedIndex ? Colors.lavender : Colors.crust

                    Image {
                        anchors.fill: parent
                        anchors.margins: entry.border.width

                        source: "file://" + WallpaperService.wallpaperDir + "/" + entry.modelData

                        fillMode: Image.PreserveAspectCrop
                        cache: true
                        smooth: true

                        layer.enabled: true
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        height: 40

                        color: Colors.base
                        opacity: 0.85

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10

                            text: entry.modelData

                            color: Colors.text

                            font {
                                family: Fonts.normal
                                pixelSize: Fonts.textSmall
                            }

                            elide: Text.ElideMiddle
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea

                        anchors.fill: parent

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            WallpaperService.setWallpaper(entry.modelData);
                            LauncherService.hide();
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "wallpapermanager"

        function toggle() {
            LauncherService.toggle("WallpaperManager");
        }
    }
}
