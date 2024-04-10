import SwiftUI

struct InstanceWorldsView: View {
    @StateObject var instance: Instance
    
    @FocusState var selectedWorld: World?
    
    var body: some View {
        List {
            ForEach(instance.worlds, id: \.self) { world in
                Text(world.folder)
                    .focusable()
                    .focused($selectedWorld, equals: world)
                    .highPriorityGesture(
                        TapGesture().onEnded {
                            selectedWorld = world
                        }
                    )
            }
        }
        .task {
            instance.loadWorldsAsync()
        }
    }
}
