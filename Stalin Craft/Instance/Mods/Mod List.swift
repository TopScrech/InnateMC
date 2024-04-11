import ScrechKit

struct ModList: View {
    @StateObject var instance: Instance
    
    @State var selected: Set<Mod> = []
    @State var sortOrder: [KeyPathComparator<Mod>] = [
        .init(\.meta.name, order: .forward)
    ]
    
    @State private var alertDelete = false
    
    var body: some View {
        VStack {
            Table(instance.mods, selection: $selected, sortOrder: $sortOrder) {
                TableColumn("Name", value: \.meta.name)
                
                TableColumn("Description", value: \.meta.description)
                
                TableColumn("File", value: \.path.lastPathComponent)
            }
            .animation(.default, value: instance.mods)
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                handleDrop(providers)
            }
            //        .onDeleteCommand {
            //            alertDelete = true
            //        }
            
            Button {
                openInFinderOrCreate(instance.getModsFolder().path)
            } label: {
                Text("Open in Finder")
            }
        }
        .task {
            instance.loadMods()
        }
        //        .alert("Delete", isPresented: $alertDelete) {
        //
        //        }
    }
}
