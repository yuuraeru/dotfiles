pragma Singleton

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string result: ""
    property string expression: ""

    property int selectedIndex: 0
    property int recalculateIndex: 2

    property var savedExpressions: ["Copy to clipboard", "Save expression"]
    property var recalculatedExpressions: ["", ""]

    property var settings: Settings {
        category: "Calculator"

        property string savedExpressionsSerialized: '["Copy to clipboard", "Save expression"]'
    }

    Component.onCompleted: {
        root.savedExpressions = JSON.parse(root.settings.savedExpressionsSerialized);
        // root.settings.savedExpressionsSerialized = JSON.stringify(root.savedExpressions);

        root.recalculateExpressions();
    }

    function calculate() {
        const expression = LauncherService.query.trim();

        if (expression === "") {
            root.expression = "";
            root.result = "";
            return;
        }

        root.result = "";
        qalcProcess.command = ["qalc", expression];
        qalcProcess.running = true;
    }

    function copyResult() {
        if (root.result.trim() === "")
            return;

        copyProcess.command = ["wl-copy", "--", root.result.trim()];
        copyProcess.running = true;
        LauncherService.hide();
    }

    function saveExpression() {
        if (root.expression.trim() === "")
            return;

        const expressions = root.savedExpressions.slice();
        expressions.splice(2, 0, root.expression);

        root.savedExpressions = expressions;
        root.settings.savedExpressionsSerialized = JSON.stringify(expressions);

        const results = root.recalculatedExpressions.slice();
        results.splice(2, 0, root.result);

        root.recalculatedExpressions = results;
    }

    function reset() {
        root.selectedIndex = 0;
    }

    function navigate(delta) {
        const count = root.savedExpressions.length;

        if (count <= 0)
            return;

        root.selectedIndex = (root.selectedIndex + delta + count) % count;
    }

    function select(index) {
        if (index === 0) {
            copyResult();
            return;
        }

        if (index === 1) {
            saveExpression();
            return;
        }

        const result = root.recalculatedExpressions[index];

        if (!result)
            return;

        copyProcess.command = ["wl-copy", "--", result];
        copyProcess.running = true;
        LauncherService.hide();
    }

    function deleteExpression(index) {
        if (index < 2 || index >= root.savedExpressions.length)
            return;

        const expressions = root.savedExpressions.slice();
        expressions.splice(index, 1);

        root.savedExpressions = expressions;
        root.settings.savedExpressionsSerialized = JSON.stringify(expressions);

        const results = root.recalculatedExpressions.slice();
        results.splice(index, 1);

        root.recalculatedExpressions = results;

        if (root.selectedIndex > index)
            root.selectedIndex--;

        if (root.selectedIndex >= expressions.length)
            root.selectedIndex = expressions.length - 1;
    }

    function recalculateExpressions() {
        root.recalculateIndex = 2;
        root.recalculatedExpressions = ["", ""];

        if (root.savedExpressions.length <= 2)
            return;

        recalculateProcess.command = ["sh", "-c", "for expression do qalc -t \"$expression\"; done", "sh", ...root.savedExpressions.slice(2)];

        recalculateProcess.running = true;
    }

    Process {
        id: qalcProcess

        stdout: SplitParser {
            onRead: data => {
                const output = data.trim();

                if (output === "")
                    return;

                const parts = output.split("=");

                if (parts.length < 2) {
                    root.result = output;
                    root.expression = "";
                    return;
                }

                root.result = parts[parts.length - 1].trim();
                root.expression = parts[parts.length - 2].trim();
            }
        }
    }

    Process {
        id: copyProcess
    }

    Process {
        id: recalculateProcess

        stdout: SplitParser {
            onRead: data => {
                const result = data.trim();

                if (result === "")
                    return;

                const results = root.recalculatedExpressions.slice();

                results[root.recalculateIndex] = result;

                root.recalculatedExpressions = results;
                root.recalculateIndex++;
            }
        }
    }
}
