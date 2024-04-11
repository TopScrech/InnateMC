import ScrechKit

struct WorldList: View {
    @StateObject var instance: Instance
    
    @FocusState var selectedWorld: World?
    
    private var savesFolder: String {
        instance.getSavesFolder().path
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(instance.worlds, id: \.self) { world in
                    let worldPath = savesFolder + "/" + world.folder
                    
                    HStack {
                        Text(world.folder)
                            .focusable()
                            .focused($selectedWorld, equals: world)
                            .highPriorityGesture(
                                TapGesture().onEnded {
                                    selectedWorld = world
                                }
                            )
                        
                        Button("Open") {
                            openInFinder(rootedAt: worldPath)
                        }
                        
                        if let size = formattedSize(worldPath) {
                            Text(size)
                        }
                    }
                }
            }
            
            Button {
                openInFinder(rootedAt: savesFolder)
            } label: {
                Text("Open in Finder")
            }
        }
        .task {
            instance.loadWorlds()
        }
    }
    
    private func formattedSize(_ stringUrl: String) -> String? {
        if let url = URL(string: stringUrl) {
            let test = try! FileManager.default.allocatedSizeOfDirectory(url)
            
            return formatBytes(test)
        }
        
        return nil
    }
}
