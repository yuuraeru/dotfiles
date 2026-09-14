pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtCore

Singleton {
    id: root

    property bool dnd: false
    property bool centerIsOpen: false

    property var popupList: []
    property var historyList: []

    property var settings: Settings {
        category: "Notification"

        property bool dnd: false
        property string historyListSerialized: "[]"
    }

    Component.onCompleted: {
        dnd = settings.dnd;
        historyList = JSON.parse(settings.historyListSerialized);
    }

    Timer {
        interval: 100
        running: root.popupList.length > 0
        repeat: true

        onTriggered: {
            const now = Date.now();

            root.popupList = root.popupList.filter(n => n.expiredAt === 0 || n.expiredAt > now);
        }
    }

    NotificationServer {
        id: server

        imageSupported: true

        onNotification: n => {
            const isCritical = n.urgency === NotificationUrgency.Critical;

            function imageHandler(source, appName) {
                const value = source || "";

                if (value.startsWith("image://qsimage/"))
                    return "";

                return value;
            }

            const data = {
                id: n.id,
                summary: n.summary,
                body: n.body,
                appName: n.appName,
                image: imageHandler(n.image, n.appName),
                isCritical: isCritical,
                time: Qt.formatDateTime(new Date(), "hh:mm AP"),
                expiredAt: isCritical ? 0 : Date.now() + 5000
            };

            root.addNotification(data);
        }
    }

    function addNotification(data) {
        root.popupList = [data, ...root.popupList];
        root.historyList = [data, ...root.historyList];
        settings.historyListSerialized = JSON.stringify(root.historyList);
    }

    function removePopup(id) {
        root.popupList = root.popupList.filter(n => n.id !== id);
    }

    function removeHistory(id) {
        root.historyList = root.historyList.filter(n => n.id !== id);
        settings.historyListSerialized = JSON.stringify(root.historyList);
    }

    function clearHistory() {
        root.historyList = [];
        settings.historyListSerialized = JSON.stringify(root.historyList);
    }

    function toggleCenter() {
        root.centerIsOpen = !root.centerIsOpen;
    }

    function showCenter() {
        root.centerIsOpen = true;
    }

    function hideCenter() {
        root.centerIsOpen = false;
    }

    function toggleDND() {
        root.dnd = !root.dnd;
        root.settings.dnd = root.dnd;
    }

    IpcHandler {
        target: "notification"

        function toggle() {
            root.toggleCenter();
        }
    }
}
