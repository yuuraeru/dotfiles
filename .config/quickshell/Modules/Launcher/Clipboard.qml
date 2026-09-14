pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Config
import qs.Services

Item {
    id: root

    implicitWidth: 960
    implicitHeight: 640

    visible: LauncherService.mode === "Clipboard"

    onVisibleChanged: {
        if (!visible)
            return;

        ClipboardService.reset();
        ClipboardService.refresh();
        textInput.forceActiveFocus();
    }

    Connections {
        target: LauncherService

        function onQueryChanged() {
            ClipboardService.updateFiltered();
        }
    }

    Rectangle {
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
                        text: "󰅌"
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

                            text: "Search clipboard..."

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
                                ClipboardService.navigate(1);
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Up || (e.key === Qt.Key_Backtab && !(e.modifiers & Qt.ControlModifier))) {
                                ClipboardService.navigate(-1);
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                if (ClipboardService.filteredEntries.length > 0) {
                                    ClipboardService.copyEntry(ClipboardService.filteredEntries[ClipboardService.selectedIndex]);
                                }

                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Delete) {
                                if (ClipboardService.filteredEntries.length > 0) {
                                    ClipboardService.deleteEntry(ClipboardService.filteredEntries[ClipboardService.selectedIndex]);
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
                id: clipboardList

                model: ClipboardService.filteredEntries

                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 10
                clip: true
                delegate: Rectangle {
                    id: entry

                    required property var modelData
                    required property int index

                    width: clipboardList.width
                    height: 80

                    radius: Config.rounding

                    color: mouseArea.containsMouse ? Colors.overlay0 : index === ClipboardService.selectedIndex ? Colors.overlay1 : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        spacing: 10

                        MouseArea {
                            id: mouseArea

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: ClipboardService.copyEntry(entry.modelData)

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10

                                Item {
                                    Layout.preferredWidth: 60
                                    Layout.preferredHeight: 60

                                    Image {
                                        anchors.fill: parent

                                        visible: entry.modelData.isImage && entry.modelData.cached

                                        source: entry.modelData.isImage && entry.modelData.cached ? "file://" + ClipboardService.cachePath(entry.modelData) : ""

                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                    }

                                    Text {
                                        anchors.fill: parent

                                        visible: !entry.modelData.isImage

                                        text: "󰅌"
                                        color: Colors.lavender

                                        font {
                                            family: Fonts.icon
                                            pixelSize: Fonts.iconNormal
                                        }

                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Text {
                                        anchors.fill: parent

                                        visible: entry.modelData.isImage && !entry.modelData.cached

                                        text: ""
                                        color: Colors.overlay1

                                        font {
                                            family: Fonts.icon
                                            pixelSize: Fonts.iconNormal
                                        }

                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter

                                        Component.onCompleted: {
                                            if (entry.modelData.isImage)
                                                ClipboardService.requestImage(entry.modelData);
                                        }
                                    }
                                }

                                Text {
                                    text: entry.modelData.preview
                                    color: Colors.text

                                    font {
                                        family: Fonts.normal
                                        pixelSize: Fonts.textNormal
                                        bold: true
                                    }

                                    elide: Text.ElideRight
                                    maximumLineCount: 3

                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40

                            radius: Config.rounding

                            color: deleteMouseArea.containsMouse ? Colors.red : Colors.base

                            Text {
                                text: "󰆴"

                                anchors.centerIn: parent

                                color: !deleteMouseArea.containsMouse ? Colors.red : Colors.base

                                font {
                                    family: Fonts.icon
                                    pixelSize: Fonts.iconNormal
                                }
                            }

                            MouseArea {
                                id: deleteMouseArea

                                anchors.fill: parent

                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: ClipboardService.deleteEntry(entry.modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "clipboard"

        function toggle() {
            LauncherService.toggle("Clipboard");
        }
    }
}
