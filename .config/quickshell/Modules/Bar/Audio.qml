import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs.Config

Rectangle {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property int vol: sink?.ready ? Math.round(sink.audio.volume * 100) : 0
    readonly property int sourceVol: source?.ready ? Math.round(source.audio.volume * 100) : 0

    readonly property string icon: {
        if (!sink?.ready || vol === 0)
            return "󰖁";

        if (sink.audio.muted)
            return "󰝟";

        if (vol < 30)
            return "󰕿";

        if (vol < 60)
            return "󰖀";

        return "󰕾";
    }

    function togglePavucontrol() {
        Quickshell.execDetached(["sh", "-c", "pkill -x pavucontrol || pavucontrol"]);
    }

    implicitWidth: row.implicitWidth + 24
    implicitHeight: Config.barSize

    radius: Config.rounding
    color: Colors.base

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: 10

        Item {
            implicitWidth: outputRow.implicitWidth
            implicitHeight: outputRow.implicitHeight

            RowLayout {
                id: outputRow

                Text {
                    text: root.icon

                    font {
                        family: Fonts.icon
                        pixelSize: Fonts.iconSmall
                    }

                    color: Colors.blue
                }

                Text {
                    text: root.sink?.audio?.muted ? "Muted" : root.vol + "%"

                    color: Colors.blue

                    font {
                        family: Fonts.normal
                        pixelSize: Fonts.textNormal
                        bold: true
                    }
                }
            }

            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: e => {
                    if (e.button === Qt.LeftButton)
                        root.sink.audio.muted = !root.sink.audio.muted;
                    else
                        root.togglePavucontrol();
                }

                onWheel: e => {
                    root.sink.audio.volume += e.angleDelta.y > 0 ? 0.05 : -0.05;
                }
            }
        }

        Item {
            implicitWidth: inputRow.implicitWidth
            implicitHeight: inputRow.implicitHeight

            RowLayout {
                id: inputRow

                Text {
                    text: root.source?.audio?.muted ? "󰍭" : "󰍬"

                    font {
                        family: Fonts.icon
                        pixelSize: Fonts.iconSmall
                    }

                    color: Colors.mauve
                }

                Text {
                    text: root.source?.audio?.muted ? "Muted" : root.sourceVol + "%"

                    color: Colors.mauve

                    font {
                        family: Fonts.normal
                        pixelSize: Fonts.textNormal
                        bold: true
                    }
                }
            }

            MouseArea {
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor

                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: e => {
                    if (e.button === Qt.LeftButton)
                        root.source.audio.muted = !root.source.audio.muted;
                    else
                        root.togglePavucontrol();
                }

                onWheel: e => {
                    root.source.audio.volume += e.angleDelta.y > 0 ? 0.05 : -0.05;
                }
            }
        }
    }

    PwObjectTracker {
        objects: [root.sink, root.source]
    }
}
