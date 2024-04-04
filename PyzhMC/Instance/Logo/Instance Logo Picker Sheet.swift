import SwiftUI

struct InstanceLogoSheet: View {
    @StateObject var instance: Instance
    
    @Binding var showLogoSheet: Bool
    
    var body: some View {
        VStack {
            TabView {
                ImageLogoPickerView(instance: instance)
                    .tabItem {
                        Text(i18n("image"))
                    }
                
                SymbolLogoPickerView(instance: instance, logo: $instance.logo)
                    .tabItem {
                        Text(i18n("symbol"))
                    }
            }
            
            Button(i18n("done")) {
                withAnimation {
                    showLogoSheet = false
                }
            }
            .padding()
            .keyboardShortcut(.cancelAction)
        }
        .padding(15)
    }
}
