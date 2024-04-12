import SwiftUI

struct InstanceDuplicationSheet: View {
    @StateObject var instance: Instance
    @EnvironmentObject private var launcherData: LauncherData
    @Environment(\.dismiss) private var dismiss
    
    @State var newName = ""
    
    var body: some View {
        VStack {
#warning("Allow selecting what and what not to duplicate")
            Form {
                TextField("Name", text: $newName)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            
            HStack {
                Button("Duplicate") {
                    let newInstance = Instance(name: newName, assetIndex: instance.assetIndex, libraries: instance.libraries, mainClass: instance.mainClass, minecraftJar: instance.minecraftJar, isStarred: false, logo: instance.logo, description: instance.notes, debugString: instance.debugString, arguments: instance.arguments)
                    
                    DispatchQueue.global(qos: .userInteractive).async {
                        do {
                            try newInstance.createAsNewInstance()
                            logger.info("Successfully duplicated instance")
                        } catch {
                            logger.error("Could not duplicate instance \(newName)", error: error)
                            
                            ErrorTracker.instance.error(
                                error: error,
                                description: "Could not duplicate instance \(newName)"
                            )
                        }
                    }
                    
                    launcherData.instances.append(newInstance)
                    dismiss()
                }
                .padding()
                
                Button("Cancel") {
                    dismiss()
                }
                .padding()
            }
        }
        .onAppear {
#warning("localize")
            newName = "Copy of \(instance.name)"
        }
    }
}
