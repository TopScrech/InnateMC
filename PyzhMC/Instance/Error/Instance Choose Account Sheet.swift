import SwiftUI

struct InstanceChooseAccountSheet: View {
    @Binding var showChooseAccountSheet: Bool
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    
                    Text(i18n("no_account_selected"))
                    
                    Spacer()
                }
                .padding()
                
                Button(i18n("close")) {
                    self.showChooseAccountSheet = false
                }
                .keyboardShortcut(.cancelAction)
                .padding()
            }
        }
    }
}
