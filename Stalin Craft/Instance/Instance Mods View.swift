import SwiftUI

struct InstanceModsView: View {
    @StateObject var instance: Instance
    
    @State var selected: Set<Mod> = []
    @State var sortOrder: [KeyPathComparator<Mod>] = [
        .init(\.meta.name, order: .forward)
    ]
    
    @State private var alertDelete = false
    
    var body: some View {
        Table(instance.mods, selection: $selected, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.meta.name)
            
            TableColumn("Description", value: \.meta.description)
            
            TableColumn("File", value: \.path.lastPathComponent)
        }
        .onDeleteCommand {
            alertDelete = true
        }
        .task {
            instance.loadModsAsync()
        }
        .alert("Delete", isPresented: $alertDelete) {
            
        }
    }
}
