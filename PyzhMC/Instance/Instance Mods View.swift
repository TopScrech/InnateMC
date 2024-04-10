import SwiftUI

struct InstanceModsView: View {
    @StateObject var instance: Instance
    
    @State var selected: Set<Mod> = []
    @State var sortOrder: [KeyPathComparator<Mod>] = [
        .init(\.meta.name, order: .forward)
    ]
    
    var body: some View {
        Table(instance.mods, selection: $selected, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.meta.name)
            
            TableColumn("File", value: \.path.lastPathComponent)
        }
        .onAppear {
            instance.loadModsAsync()
        }
    }
}
