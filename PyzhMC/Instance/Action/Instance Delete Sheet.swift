import SwiftUI

struct InstanceDeleteSheet: View {
    @EnvironmentObject var launcherData: LauncherData
    @Binding var showDeleteSheet: Bool
    @Binding var selectedInstance: Instance?
    
    var instanceToDelete: Instance
    
    var body: some View {
        VStack(alignment: .center) {
            Text(i18n("are_you_sure_delete_instance"))
            
            HStack {
                Button(i18n("delete")) {
                    if let index = launcherData.instances.firstIndex(of: self.instanceToDelete) {
                        if let selectedInstance = self.selectedInstance {
                            if selectedInstance == instanceToDelete {
                                self.selectedInstance = nil
                            }
                        }
                        
                        let instance = launcherData.instances.remove(at: index)
                        instance.delete()
                    }
                    
                    showDeleteSheet = false
                }
                .padding()
                
                Button(i18n("cancel")) {
                    showDeleteSheet = false
                }
                .padding()
            }
        }
        .padding(.all, 20)
    }
}
