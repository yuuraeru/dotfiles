pragma Singleton

import Quickshell

Singleton {
    id: root

    property bool isOpen: false
    property string mode: ""
    property string query: ""

    property var launchers: ["AppLauncher", "Calculator", "WallpaperManager"]

    function toggle(name) {
        if (root.isOpen && root.mode === name) {
            root.hide();
            return;
        }

        root.show(name);
    }

    function show(name) {
        root.mode = name;
        root.isOpen = true;
    }

    function hide() {
        root.isOpen = false;
        root.mode = "";
        root.query = "";
    }

    function cycle(delta) {
        if (root.launchers.length === 0)
            return;

        let index = root.launchers.indexOf(root.mode);

        if (index === -1)
            index = 0;
        else
            index = (index + delta + root.launchers.length) % root.launchers.length;

        root.mode = root.launchers[index];
    }
}
