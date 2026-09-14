import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Config

Rectangle {
    id: root

    implicitWidth: monitorText.implicitWidth + 24
    implicitHeight: Config.barSize

    radius: Config.rounding
    color: Colors.base

    property string cpuUsage: "0"
    property string cpuTemp: "N/A"
    property string memoryUsage: "0"

    Process {
        id: cpu

        command: ["sh", "-c", "top -bn1 | awk '/Cpu\\(s\\)/ {printf \"%.0f\", 100 - $8; exit}'"]

        stdout: SplitParser {
            onRead: data => root.cpuUsage = data.trim()
        }

        Component.onCompleted: running = true
    }

    Process {
        id: temp

        command: ["sh", "-c", "sensors | awk '/Tctl:/ {printf \"%.0f\", $2; exit}'"]

        stdout: SplitParser {
            onRead: data => root.cpuTemp = data.trim()
        }

        Component.onCompleted: running = true
    }

    Process {
        id: memory

        command: ["sh", "-c", "free -b | awk '/Mem:/ {printf \"%.1fGiB/%.1fGiB\", $3/1024/1024/1024, $2/1024/1024/1024; exit}'"]

        stdout: SplitParser {
            onRead: data => root.memoryUsage = data.trim()
        }

        Component.onCompleted: running = true
    }

    Timer {
        interval: 4000
        running: true
        repeat: true

        onTriggered: {
            cpu.running = true;
            temp.running = true;
            memory.running = true;
        }
    }

    RowLayout {
        id: monitorText

        anchors.centerIn: parent

        Text {
            text: ""
            font {
                family: Fonts.icon
                pixelSize: Fonts.iconSmall
            }
            color: Colors.blue
        }
        Text {
            text: root.cpuUsage + "%"
            font {
                family: Fonts.normal
                pixelSize: Fonts.textNormal
                bold: true
            }
            color: Colors.blue
        }
        Text {
            text: " "
            font {
                family: Fonts.icon
                pixelSize: Fonts.iconSmall
            }
            color: Colors.pink
        }
        Text {
            text: root.cpuTemp + "°C"
            font {
                family: Fonts.normal
                pixelSize: Fonts.textNormal
                bold: true
            }
            color: Colors.pink
        }
        Text {
            text: " "
            font {
                family: Fonts.icon
                pixelSize: Fonts.iconSmall
            }
            color: Colors.green
        }
        Text {
            text: root.memoryUsage
            font {
                family: Fonts.normal
                pixelSize: Fonts.textNormal
                bold: true
            }
            color: Colors.green
        }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["sh", "-c", "pkill -x btop  || kitty -e btop"])
    }
}
