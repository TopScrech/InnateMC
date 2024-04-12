import SwiftUI

struct DeveloperModeCommands: Commands {
    @AppStorage("developerMode") var developerMode = true
    
    var body: some Commands {
        getCommands()
    }
    
    func getCommands() -> some Commands {
        if #available(macOS 13, *) {
            return getNewCommands()
        } else {
            return getOldCommands()
        }
    }
    
    @CommandsBuilder
    func getOldCommands() -> some Commands {
        CommandMenu("Develop") {
            if developerMode {
                createView()
            }
        }
    }
    
    @ViewBuilder
    func createView() -> some View {
        Button("Show console") {
            Task {
                let workspace = NSWorkspace.shared
                let consoleURL = URL(fileURLWithPath: "/System/Applications/Utilities/Console.app")
                let appURL = Bundle.main.bundleURL
                let config = NSWorkspace.OpenConfiguration()
                
                config.arguments = [appURL.path]
                
                try! await workspace.openApplication(at: consoleURL, configuration: config)
            }
        }
        
        Button("Error Tracker") {
            ErrorTracker.instance.showWindow()
        }
    }
    
    @CommandsBuilder
    @available(macOS 13, *)
    func getNewCommands() -> some Commands {
        if developerMode {
            CommandMenu("Develop") {
                createView()
            }
        }
    }
}
