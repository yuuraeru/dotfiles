//@ pragma UseQApplication
import Quickshell

import qs.Modules
import qs.Modules.Bar
import qs.Modules.Notification
import qs.Modules.Launcher

ShellRoot {
    id: root

    // I don't have second monitor anymore, unable to test if variants works
    Variants {
        model: Quickshell.screens
        Wallpaper {
            property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens
        Bar {
            modelData: modelData
        }
    }

    NotificationCenter {}
    NotificationPopup {}

    Launcher {}
}
