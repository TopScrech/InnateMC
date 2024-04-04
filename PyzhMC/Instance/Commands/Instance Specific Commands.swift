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
                Text("Unstar")
                
                Image(systemName: "star.slash")
            } else {
                Text("Star")
                
                Image(systemName: "star")
            }
        }
        .disabled(selectedInstance == nil)
        .keyboardShortcut("f")
        .onChange(of: selectedInstance) { newValue in
            if let newValue {
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
            if let selectedInstance {
                self.instanceIsntLaunched = !value.contains(where: { $0.0 == selectedInstance })
            } else {
                self.instanceIsntLaunched = true
            }
        }
        .onReceive(LauncherData.instance.$editModeInstances) { value in
            if let selectedInstance {
                self.instanceIsntInEdit = !value.contains(where: { $0 == selectedInstance })
            } else {
                self.instanceIsntInEdit = true
            }
        }
        
        if instanceIsntLaunched {
            Button {
                LauncherData.instance.launchRequestedInstances.append(selectedInstance!)
            } label: {
                Text("launch")
                
                Image(systemName: "paperplane")
            }
            .keyboardShortcut(.return)
            .disabled(selectedInstance == nil)
        } else {
            Button {
                LauncherData.instance.killRequestedInstances.append(selectedInstance!)
            } label: {
                Text("kill")
                
                Image(systemName: "square.fill")
            }
        }
        
        if instanceIsntInEdit {
            Button {
                LauncherData.instance.editModeInstances.append(selectedInstance!)
            } label: {
                Text("Edit")
                
                Image(systemName: "pencil")
            }
            .keyboardShortcut(KeyEquivalent("e"))
            .disabled(selectedInstance == nil)
        } else {
            Button {
                LauncherData.instance.editModeInstances.removeAll(where: { $0 == selectedInstance! })
            } label: {
                Text("Save")
                
                Image(systemName: "checkmark")
            }
            .keyboardShortcut(KeyEquivalent("s"))
        }
        
        Button {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: selectedInstance!.getPath().path)
        } label: {
            Text("Open in finder")
            
            Image(systemName: "folder")
        }
        .keyboardShortcut(KeyEquivalent.upArrow)
        .disabled(selectedInstance == nil)
        
        if let selectedInstance {
            Divider()
                .onReceive(selectedInstance.$isStarred) { value in
                    self.instanceStarred = value
                }
        } else {
            Divider()
        }
    }
}
