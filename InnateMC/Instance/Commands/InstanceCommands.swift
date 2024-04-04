import SwiftUI

struct InstanceCommands: Commands {
    var body: some Commands {
        CommandMenu(i18n("instance")) {
            if #available(macOS 13, *) {
                InstanceSpecificCommands()
            }
            
            Button(i18n("open_instances_folder")) {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: FileHandler.instancesFolder.path)
            }
            .keyboardShortcut(.upArrow, modifiers: [.shift, .command])
            
            Button(i18n("new_instance")) {
                DispatchQueue.main.async {
                    LauncherData.instance.newInstanceRequested = true
                }
            }
            .keyboardShortcut("n")
        }
    }
}
