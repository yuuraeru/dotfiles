import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Config
import qs.Services

Item {
    id: root

    implicitWidth: 760
    implicitHeight: 480

    visible: LauncherService.mode === "Calculator"

    onVisibleChanged: {
        if (!visible)
            return;

        CalculatorService.reset();
        CalculatorService.calculate();
        textInput.forceActiveFocus();
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
                radius: Config.rounding

                Layout.fillWidth: true
                Layout.preferredHeight: 100

                Text {
                    anchors {
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                        margins: 10
                    }

                    text: CalculatorService.result !== "" ? CalculatorService.result : "Result"

                    verticalAlignment: Text.AlignVCenter

                    color: CalculatorService.result !== "" ? Colors.text : Colors.overlay0

                    font {
                        family: Fonts.normal
                        pixelSize: Fonts.textLarge
                    }
                }
            }

            Rectangle {
                color: Colors.crust
                radius: Config.rounding

                Layout.fillWidth: true
                Layout.preferredHeight: 40

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    Text {
                        text: ""
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

                            CalculatorService.calculate();
                        }

                        Text {
                            anchors.fill: parent

                            text: "Calculate..."

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
                                CalculatorService.navigate(1);
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Up || (e.key === Qt.Key_Backtab && !(e.modifiers & Qt.ControlModifier))) {
                                CalculatorService.navigate(-1);
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                CalculatorService.select(CalculatorService.selectedIndex);
                                e.accepted = true;
                                return;
                            }

                            if (e.key === Qt.Key_Delete) {
                                CalculatorService.deleteExpression(CalculatorService.selectedIndex);
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
                id: listView

                model: CalculatorService.savedExpressions

                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 10
                clip: true

                delegate: Rectangle {
                    id: expression

                    required property var modelData
                    required property int index

                    width: parent.width
                    height: 50
                    radius: Config.rounding

                    color: mouseArea.containsMouse ? Colors.overlay0 : index === CalculatorService.selectedIndex ? Colors.overlay0 : "transparent"

                    RowLayout {
                        anchors.fill: parent

                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        spacing: 10

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            RowLayout {
                                anchors.fill: parent

                                spacing: 10

                                Text {
                                    text: expression.index === 0 ? "󰅌" : "󰠘"

                                    visible: expression.index < 2

                                    color: Colors.lavender

                                    font {
                                        family: Fonts.icon
                                        pixelSize: Fonts.iconNormal
                                    }

                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Text {
                                    text: expression.modelData

                                    color: Colors.text

                                    Layout.fillWidth: true

                                    verticalAlignment: Text.AlignVCenter

                                    font {
                                        family: Fonts.normal
                                        pixelSize: Fonts.textNormal
                                        bold: true
                                    }
                                }

                                Text {
                                    text: CalculatorService.recalculatedExpressions[expression.index]

                                    color: Colors.text

                                    horizontalAlignment: Text.AlignRight
                                    verticalAlignment: Text.AlignVCenter

                                    font {
                                        family: Fonts.normal
                                        pixelSize: Fonts.textNormal
                                        bold: true
                                    }
                                }
                            }

                            MouseArea {
                                id: mouseArea

                                anchors.fill: parent

                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    CalculatorService.select(expression.index);
                                }
                            }
                        }

                        Rectangle {
                            visible: expression.index >= 2

                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40

                            radius: Config.rounding

                            color: deleteMouseArea.containsMouse ? Colors.red : Colors.base

                            Text {
                                anchors.centerIn: parent

                                text: "󰆴"
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

                                onClicked: {
                                    CalculatorService.deleteExpression(expression.index);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "calculator"

        function toggle() {
            LauncherService.toggle("Calculator");
        }
    }
}
