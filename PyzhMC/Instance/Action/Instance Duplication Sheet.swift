
import SwiftUI

struct InstanceDuplicationSheet: View {
    @EnvironmentObject var launcherData: LauncherData
    @Binding var showDuplicationSheet: Bool
    @StateObject var instance: Instance
    
    @State var newName = ""
    
    var body: some View {
        VStack {
            // TODO: allow selecting what and what not to duplicate
            Form {
                TextField(i18n("name"), text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            HStack {
                Button(i18n("duplicate")) {
                    let newInstance = Instance(name: self.newName, assetIndex: instance.assetIndex, libraries: instance.libraries, mainClass: instance.mainClass, minecraftJar: instance.minecraftJar, isStarred: false, logo: instance.logo, description: instance.notes, debugString: instance.debugString, arguments: instance.arguments)
                    
                    DispatchQueue.global(qos: .userInteractive).async {
                        do {
                            try newInstance.createAsNewInstance()
                            logger.info("Successfully duplicated instance")
                        } catch {
                            logger.error("Could not duplicate instance \(newName)", error: error)
                            ErrorTracker.instance.error(error: error, description: "Could not duplicate instance \(newName)")
                        }
                    }
                    
                    self.launcherData.instances.append(newInstance)
                    self.showDuplicationSheet = false
                }
                .padding()
                
                Button(i18n("cancel")) {
                    self.showDuplicationSheet = false
                }
                .padding()
            }
        }
        .onAppear {
            self.newName = "Copy of \(instance.name)" // TODO: localize
        }
    }
}
