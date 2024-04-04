import SwiftUI

struct InstanceDeleteSheet: View {
    @EnvironmentObject var launcherData: LauncherData
    @Binding var sheetDelete: Bool
    @Binding var selectedInstance: Instance?
    
    var instanceToDelete: Instance
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Authenticating with Microsoft")
            
            HStack {
                Button("Delete") {
                    if let index = launcherData.instances.firstIndex(of: self.instanceToDelete) {
                        if let selectedInstance {
                            if selectedInstance == instanceToDelete {
                                self.selectedInstance = nil
                            }
                        }
                        
                        let instance = launcherData.instances.remove(at: index)
                        instance.delete()
                    }
                    
                    sheetDelete = false
                }
                .padding()
                
                Button("Cancel") {
                    sheetDelete = false
                }
                .padding()
            }
        }
        .padding(20)
    }
}
