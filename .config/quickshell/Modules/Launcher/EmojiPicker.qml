import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Config
import qs.Services

Item {
    id: root

    implicitWidth: 960
    implicitHeight: 720

    visible: LauncherService.mode === "EmojiPicker"

    property var entries: []
    property var filteredEntries: []
    property int selectedIndex: 0
    property var loadingEntries: []

    function reset() {
        root.selectedIndex = 0;
    }

    function updateFiltered() {
        const q = LauncherService.query.trim().toLowerCase();

        if (q === "") {
            root.filteredEntries = root.entries;
        } else {
            root.filteredEntries = root.entries.filter(entry => entry.search.includes(q));
        }

        if (root.filteredEntries.length === 0) {
            root.selectedIndex = 0;
            return;
        }

        if (root.selectedIndex >= root.filteredEntries.length)
            root.selectedIndex = root.filteredEntries.length - 1;
    }

    function navigate(delta) {
        const count = root.filteredEntries.length;

        if (count <= 0)
            return;

        root.selectedIndex = (root.selectedIndex + delta + count) % count;
    }

    function copyEmoji(entry) {
        if (!entry)
            return;

        copyProcess.command = ["wl-copy", "--", entry.emoji];
        copyProcess.running = true;

        LauncherService.hide();
    }

    onVisibleChanged: {
        if (!visible)
            return;

        root.reset();
        root.updateFiltered();
        textInput.forceActiveFocus();
    }

    Connections {
        target: LauncherService

        function onQueryChanged() {
            root.updateFiltered();
        }
    }

    Process {
        id: emojiProcess

        command: ["cat", Quickshell.shellDir + "/all_emojis.txt"]

        stdout: SplitParser {
            onRead: data => {
                const line = data.replace(/\r?\n$/, "");

                if (!line)
                    return;

                const fields = line.split("\t");

                if (fields.length < 5)
                    return;

                root.loadingEntries.push({
                    emoji: fields[0],
                    name: fields[3],
                    search: fields.join(" ").toLowerCase()
                });
            }
        }

        onRunningChanged: {
            if (running) {
                root.loadingEntries = [];
                root.entries = [];
                root.filteredEntries = [];
                root.selectedIndex = 0;
                return;
            }

            root.entries = root.loadingEntries;
            root.loadingEntries = [];
            root.updateFiltered();
        }
    }

    Process {
        id: copyProcess
    }

    Component.onCompleted: {
        emojiProcess.running = true;
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
                        text: "󰞅"
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

                            text: "Search emoji..."

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
                                root.navigate(1);
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Up || (e.key === Qt.Key_Backtab && !(e.modifiers & Qt.ControlModifier))) {
                                root.navigate(-1);
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                if (root.filteredEntries.length > 0)
                                    root.copyEmoji(root.filteredEntries[root.selectedIndex]);

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

            GridView {
                id: emojiGrid

                model: root.filteredEntries

                Layout.fillWidth: true
                Layout.fillHeight: true

                property int cellSize: width / 8

                cellWidth: cellSize
                cellHeight: cellSize

                clip: true

                delegate: Rectangle {
                    id: entry

                    required property var modelData
                    required property int index

                    width: emojiGrid.cellSize
                    height: emojiGrid.cellSize

                    color: "transparent"

                    Rectangle {
                        color: mouseArea.containsMouse ? Colors.overlay0 : entry.index === root.selectedIndex ? Colors.overlay1 : "transparent"

                        width: parent.width - 10
                        height: parent.height - 10

                        anchors.centerIn: parent

                        radius: Config.rounding

                        Column {
                            anchors.fill: parent
                            anchors.margins: 5

                            spacing: 4

                            Text {
                                width: parent.width
                                height: 55

                                text: entry.modelData.emoji

                                font {
                                    family: Fonts.emoji
                                    pixelSize: 42
                                }

                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                width: parent.width
                                height: 25

                                text: entry.modelData.name

                                color: Colors.text

                                font {
                                    family: Fonts.normal
                                    pixelSize: Fonts.textSmall
                                }

                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter

                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: mouseArea

                            anchors.fill: parent

                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.copyEmoji(entry.modelData);
                            }
                        }
                    }
                }

                onCurrentIndexChanged: {
                    if (currentIndex >= 0 && currentIndex !== root.selectedIndex) {
                        root.selectedIndex = currentIndex;
                    }
                }

                Connections {
                    target: root

                    function onSelectedIndexChanged() {
                        emojiGrid.currentIndex = root.selectedIndex;
                        emojiGrid.positionViewAtIndex(root.selectedIndex, GridView.Contain);
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "emoji"

        function toggle() {
            LauncherService.toggle("EmojiPicker");
        }
    }
}
