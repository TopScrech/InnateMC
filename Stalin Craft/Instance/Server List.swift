import SwiftUI

struct ServerList: View {
    @Environment private var instance: Instance
    
    var body: some View {
        VStack {
            List {
                
            }
        }
        .task {
            let url = instance.getPath()
            print(url)
        }
    }
}

//#Preview {
//    ServerList()
//}
