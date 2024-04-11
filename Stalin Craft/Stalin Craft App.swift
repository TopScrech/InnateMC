import ScrechKit
import os

@main
struct StalinCraftApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var launcherData = LauncherData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(launcherData)
        }
        .commands {
            InstanceCommands()
            
            SidebarCommands()
            
            DeveloperModeCommands()
        }
        
        Settings {
            PreferencesView()
                .environmentObject(launcherData)
                .frame(width: 900, height: 450)
        }
    }
}

let logger = Logger(subsystem: "global", category: "Stalin Craft")

extension Logger {
    func error(_ message: String, error: Error) {
        self.error("\(message): \(error.localizedDescription)")
    }
}
