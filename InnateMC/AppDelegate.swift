//
// Copyright © 2022 Shrish Deshpande
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.
//

import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let m = NSApp.mainMenu?.item(withTitle: "Edit") {
            NSApp.mainMenu?.removeItem(m)
        }
        NSApp.windows.forEach { window in
            print(type(of: window.contentViewController))
            print(window.title)
        }
        if let preferencesWindow = NSApp.windows.first(where: { $0.title == "Preferences" }) {
            NotificationCenter.default.addObserver(forName: NSApplication.didHideNotification, object: preferencesWindow, queue: nil) { notification in
                NSLog("gitchee gitchee goo")
            }
        } else {
            NSLog("Error: %@", "Could not find Preferences window. Preferences will not be saved.")
        }
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
}
