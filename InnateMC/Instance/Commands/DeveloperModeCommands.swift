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
        CommandMenu(i18n("develop")) {
            if developerMode {
                createView()
            }
        }
    }
    
    @ViewBuilder
    func createView() -> some View {
        Button(i18n("show_console")) {
            Task {
                let workspace = NSWorkspace.shared
                let consoleURL = URL(fileURLWithPath: "/System/Applications/Utilities/Console.app")
                let appURL = Bundle.main.bundleURL
                let config: NSWorkspace.OpenConfiguration = .init()
                
                config.arguments = [appURL.path]
                
                try! await workspace.openApplication(at: consoleURL, configuration: config)
            }
        }
        
        Button(i18n("error_tracker")) {
            ErrorTracker.instance.showWindow()
        }
    }
    
    @available(macOS 13, *)
    @CommandsBuilder
    func getNewCommands() -> some Commands {
        if developerMode {
            CommandMenu(i18n("develop")) {
                createView()
            }
        }
    }
}
