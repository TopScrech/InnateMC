import SwiftUI

struct InstanceSpecificCommands: View {
    @FocusedValue(\.selectedInstance) private var selectedInstance: Instance?
    
    @State private var instanceIsntSelected = true
    @State private var instanceStarred = false
    @State private var instanceIsntLaunched = true
    @State private var instanceIsntInEdit = true
    
    var body: some View {
        Button {
            if let instance = selectedInstance {
                withAnimation {
                    instance.isStarred = !instance.isStarred
                }
            }
        } label: {
            if instanceStarred {
                Text(i18n("unstar"))
                
                Image(systemName: "star.slash")
            } else {
                Text(i18n("star"))
                
                Image(systemName: "star")
            }
        }
        .disabled(selectedInstance == nil)
        .keyboardShortcut("f")
        .onChange(of: selectedInstance) { newValue in
            if let newValue = newValue {
                self.instanceStarred = newValue.isStarred
                self.instanceIsntLaunched = !LauncherData.instance.launchedInstances.contains(where: { $0.0 == newValue })
                self.instanceIsntInEdit = !LauncherData.instance.editModeInstances.contains(where: { $0 == newValue })
            } else {
                self.instanceStarred = false
                self.instanceIsntLaunched = true
                self.instanceIsntInEdit = true
            }
            
            self.instanceIsntSelected = newValue == nil
            
            logger.trace("\(selectedInstance?.name ?? "No instance") has been selected")
        }
        .onReceive(LauncherData.instance.$launchedInstances) { value in
            if let selectedInstance = selectedInstance {
                self.instanceIsntLaunched = !value.contains(where: { $0.0 == selectedInstance })
            } else {
                self.instanceIsntLaunched = true
            }
        }
        .onReceive(LauncherData.instance.$editModeInstances) { value in
            if let selectedInstance = selectedInstance {
                self.instanceIsntInEdit = !value.contains(where: { $0 == selectedInstance })
            } else {
                self.instanceIsntInEdit = true
            }
        }
        
        if instanceIsntLaunched {
            Button {
                LauncherData.instance.launchRequestedInstances.append(selectedInstance!)
            } label: {
                Text(i18n("launch"))
                
                Image(systemName: "paperplane")
            }
            .keyboardShortcut(.return)
            .disabled(selectedInstance == nil)
        } else {
            Button {
                LauncherData.instance.killRequestedInstances.append(selectedInstance!)
            } label: {
                Text(i18n("kill"))
                
                Image(systemName: "square.fill")
            }
        }
        
        if instanceIsntInEdit {
            Button {
                LauncherData.instance.editModeInstances.append(selectedInstance!)
            } label: {
                Text(i18n("edit"))
                
                Image(systemName: "pencil")
            }
            .keyboardShortcut(KeyEquivalent("e"))
            .disabled(selectedInstance == nil)
        } else {
            Button {
                LauncherData.instance.editModeInstances.removeAll(where: { $0 == selectedInstance! })
            } label: {
                Text(i18n("save"))
                
                Image(systemName: "checkmark")
            }
            .keyboardShortcut(KeyEquivalent("s"))
        }
        
        Button {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: selectedInstance!.getPath().path)
        } label: {
            Text(i18n("open_in_finder"))
            
            Image(systemName: "folder")
        }
        .keyboardShortcut(KeyEquivalent.upArrow)
        .disabled(selectedInstance == nil)
        
        if let selectedInstance = selectedInstance {
            Divider()
                .onReceive(selectedInstance.$isStarred) { value in
                    self.instanceStarred = value
                }
        } else {
            Divider()
        }
    }
}
