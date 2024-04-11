import ScrechKit

struct WorldsList: View {
    @StateObject var instance: Instance
    
    @FocusState var selectedWorld: World?
    
    var body: some View {
        List {
            ForEach(instance.worlds, id: \.self) { world in
                let savesPath = instance.getSavesFolder().path
                let worldPath = savesPath + "/" + world.folder
                
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
