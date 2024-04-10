import SwiftUI

struct NewInstanceView: View {
    @Binding var showNewInstanceSheet: Bool
    
    var body: some View {
        TabView {
            NewVanillaInstanceView(sheetNewInstance: $showNewInstanceSheet)
                .tabItem {
                    Text("Vanilla")
                }
            //            TodoView()
            //                .tabItem {
            //                    Text("Modrinth")
            //                }
            //
            //            TodoView()
            //                .tabItem {
            //                    Text("Import")
            //                }
        }
        .border(.red, width: 0)
        .padding(14)
    }
}

#Preview {
    NewInstanceView(showNewInstanceSheet: .constant(true))
}
