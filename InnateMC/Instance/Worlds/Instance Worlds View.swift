import SwiftUI

struct InstanceWorldsView: View {
    @StateObject var instance: Instance
    
    @FocusState var selectedWorld: World?
    
    var body: some View {
        VStack {
            List {
                ForEach(instance.worlds, id: \.self) { world in
                    HStack {
                        Text(world.folder)
                    }
                    .focusable()
                    .focused($selectedWorld, equals: world)
                    .highPriorityGesture(
                        TapGesture().onEnded { i in
                            self.selectedWorld = world
                        }
                    )
                }
            }
        }
        .onAppear {
            instance.loadWorldsAsync()
        }
    }
}
