import SwiftUI

struct NewInstanceView: View {
    @Binding var showNewInstanceSheet: Bool
    
    var body: some View {
        TabView {
            NewVanillaInstanceView(showNewInstanceSheet: $showNewInstanceSheet)
                .tabItem {
                    Text(i18n("vanilla"))
                }
            //            TodoView()
            //                .tabItem {
            //                    Text(i18n("modrinth"))
            //                }
            //
            //            TodoView()
            //                .tabItem {
            //                    Text(i18n("import"))
            //                }
        }
        .border(.red, width: 0)
        .padding(14)
    }
}

#Preview {
    NewInstanceView(showNewInstanceSheet: .constant(true))
}
