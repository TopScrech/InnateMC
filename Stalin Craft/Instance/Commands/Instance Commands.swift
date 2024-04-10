import SwiftUI

struct InstanceCommands: Commands {
    var body: some Commands {
        CommandMenu("Instance") {
            if #available(macOS 13, *) {
                InstanceSpecificCommands()
            }
            
            Button("Open Instances Folder") {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: FileHandler.instancesFolder.path)
            }
            .keyboardShortcut(.upArrow, modifiers: [.shift, .command])
            
            Button("New Instance") {
                DispatchQueue.main.async {
                    LauncherData.instance.newInstanceRequested = true
                }
            }
            .keyboardShortcut("n")
        }
    }
}
