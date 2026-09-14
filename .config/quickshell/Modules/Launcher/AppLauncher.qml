import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Config
import qs.Services

Item {
    id: root

    visible: LauncherService.isOpen && LauncherService.mode === "AppLauncher"

    implicitWidth: 960
    implicitHeight: 640

    onVisibleChanged: {
        if (!visible)
            return;

        AppLauncherService.reset();
        textInput.forceActiveFocus();
    }

    Connections {
        target: AppLauncherService

        function onSelectedIndexChanged() {
            appList.positionViewAtIndex(AppLauncherService.selectedIndex, ListView.Contain);
        }
    }

    Rectangle {
        id: launcher

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
                        text: ""
                        color: Colors.lavender

                        font {
                            family: Fonts.icon
                            pixelSize: Fonts.iconNormal
                        }

                        Layout.alignment: Qt.AlignVCenter
                    }

                    TextInput {
                        id: textInput

                        text: LauncherService.query
                        color: Colors.text

                        font {
                            family: Fonts.normal
                            pixelSize: Fonts.textNormal
                        }

                        Layout.fillWidth: true
                        Layout.preferredHeight: 32

                        verticalAlignment: Text.AlignVCenter
                        clip: true

                        onTextChanged: {
                            if (LauncherService.query !== text)
                                LauncherService.query = text;

                            AppLauncherService.reset();
                        }

                        Text {
                            anchors.fill: parent

                            text: "Search..."

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

                            if (e.key === Qt.Key_Down || (e.key === Qt.Key_Tab && !(e.modifiers & Qt.ControlModifier))) {
                                AppLauncherService.navigate(1);
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Up || (e.key === Qt.Key_Backtab && !(e.modifiers & Qt.ControlModifier))) {
                                AppLauncherService.navigate(-1);
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                if (AppLauncherService.filteredApps.length > 0) {
                                    AppLauncherService.launch(AppLauncherService.filteredApps[AppLauncherService.selectedIndex]);
                                }

                                e.accepted = true;
                                return;
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
                id: appList

                model: AppLauncherService.filteredApps

                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 10
                clip: true

                delegate: Rectangle {
                    id: entry

                    required property var modelData
                    required property int index

                    width: appList.width
                    height: 60

                    radius: Config.rounding

                    color: mouseArea.containsMouse ? Colors.overlay0 : index === AppLauncherService.selectedIndex ? Colors.overlay0 : "transparent"

                    RowLayout {
                        anchors.fill: parent

                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Image {
                            source: entry.modelData.icon !== "" ? "image://icon/" + entry.modelData.icon : ""

                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40

                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: entry.modelData.name
                            color: Colors.text

                            font {
                                family: Fonts.normal
                                pixelSize: Fonts.textNormal
                                bold: true
                            }

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            AppLauncherService.launch(entry.modelData);
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle() {
            LauncherService.toggle("AppLauncher");
        }
    }
}
