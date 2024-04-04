import SwiftUI

public class InstanceEditingViewModel: ObservableObject {
    @Published var inEditMode = false
    @Published var name = ""
    @Published var synopsis = ""
    @Published var notes = ""
    
    public func start(from instance: Instance) {
        self.name = instance.name
        self.synopsis = instance.synopsis ?? ""
        self.notes = instance.notes ?? ""
        self.inEditMode = true
    }
    
    public func commit(to instance: Instance, showNoNamePopover: Binding<Bool>, showDuplicateNamePopover: Binding<Bool>, data launcherData: LauncherData) {
        showNoNamePopover.wrappedValue = false
        showDuplicateNamePopover.wrappedValue = false
        self.inEditMode = false
        instance.notes = self.notes == "" ? nil : self.notes
        instance.synopsis = self.synopsis == "" ? nil : self.synopsis
        
        if self.name != instance.name && !self.name.isEmpty {
            let trimmedName = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedName.isEmpty {
                showNoNamePopover.wrappedValue = true
                return
            }
            
            if launcherData.instances.map({ $0.name }).contains(where: { $0.lowercased() == trimmedName.lowercased()}) {
                showDuplicateNamePopover.wrappedValue = true
                return
            }
            
            instance.renameAsync(to: self.name)
            logger.info("Successfully edited instance \(instance.name)")
        }
    }
}
