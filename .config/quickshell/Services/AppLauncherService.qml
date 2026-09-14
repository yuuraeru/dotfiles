pragma Singleton

import QtQuick
import QtCore
import Quickshell

Singleton {
    id: root

    property int selectedIndex: 0
    property var recentIds: []

    property var settings: Settings {
        category: "AppLauncher"

        property string recentIdsSerialized: "[]"
    }

    property var filteredApps: {
        const q = LauncherService.query.trim().toLowerCase();

        const entries = DesktopEntries.applications.values.filter(app => {
            const name = app.name?.toLowerCase() ?? "";
            const genericName = app.genericName?.toLowerCase() ?? "";

            return q === "" || name.includes(q) || genericName.includes(q);
        });

        return entries.sort((a, b) => {
            const recentA = root.recentIds.indexOf(a.id);
            const recentB = root.recentIds.indexOf(b.id);

            if (recentA !== -1 && recentB !== -1)
                return recentA - recentB;

            if (recentA !== -1)
                return -1;

            if (recentB !== -1)
                return 1;

            return a.name.localeCompare(b.name);
        });
    }

    Component.onCompleted: {
        root.recentIds = JSON.parse(root.settings.recentIdsSerialized);
    }

    function reset() {
        root.selectedIndex = 0;
    }

    function navigate(delta) {
        const count = root.filteredApps.length;

        if (count <= 0)
            return;

        root.selectedIndex = (root.selectedIndex + delta + count) % count;
    }

    function recordLaunch(id) {
        let list = root.recentIds.slice();
        const index = list.indexOf(id);

        if (index !== -1)
            list.splice(index, 1);

        list.unshift(id);

        if (list.length > 12)
            list = list.slice(0, 12);

        root.recentIds = list;
        root.settings.recentIdsSerialized = JSON.stringify(list);
    }

    function launch(app) {
        root.recordLaunch(app.id);
        app.execute();
        LauncherService.hide();
    }
}
