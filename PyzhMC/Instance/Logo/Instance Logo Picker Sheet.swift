import SwiftUI

struct InstanceLogoSheet: View {
    @StateObject var instance: Instance
    
    @Binding var sheetLogo: Bool
    
    var body: some View {
        VStack {
            TabView {
                ImageLogoPickerView(instance: instance)
                    .tabItem {
                        Text("Image")
                    }
                
                SymbolLogoPickerView(instance: instance, logo: $instance.logo)
                    .tabItem {
                        Text("Symbol")
                    }
            }
            
            Button("Done") {
                withAnimation {
                    sheetLogo = false
                }
            }
            .padding()
            .keyboardShortcut(.cancelAction)
        }
        .padding(15)
    }
}
