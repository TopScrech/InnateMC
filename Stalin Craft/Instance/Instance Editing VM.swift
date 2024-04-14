import SwiftUI

final class InstanceEditingVM: ObservableObject {
    @Published var inEditMode = false
    @Published var name = ""
    @Published var synopsis = ""
    @Published var notes = ""
    
    func start(from instance: Instance) {
        name = instance.name
        synopsis = instance.synopsis ?? ""
        notes = instance.notes ?? ""
        inEditMode = true
    }
    
    func commit(to instance: Instance, showNoNamePopover: Binding<Bool>, showDuplicateNamePopover: Binding<Bool>, data launcherData: LauncherData) {
        showNoNamePopover.wrappedValue = false
        showDuplicateNamePopover.wrappedValue = false
        inEditMode = false
        
        instance.notes = notes == "" ? nil : notes
        instance.synopsis = synopsis == "" ? nil : synopsis
        
        if name != instance.name && !name.isEmpty {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedName.isEmpty {
                showNoNamePopover.wrappedValue = true
                return
            }
            
            if launcherData.instances.map({ $0.name }).contains(where: { $0.lowercased() == trimmedName.lowercased() }) {
                showDuplicateNamePopover.wrappedValue = true
                return
            }
            
            instance.renameAsync(to: name)
            
            logger.info("Successfully edited instance \(instance.name)")
        }
    }
}
