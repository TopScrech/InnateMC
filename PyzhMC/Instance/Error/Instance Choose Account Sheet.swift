import SwiftUI

struct InstanceChooseAccountSheet: View {
    @Binding var sheetChooseAccount: Bool
    
    var body: some View {
        VStack {
            Text("No account")
                .padding()
            
            Button("Close") {
                sheetChooseAccount = false
            }
            .keyboardShortcut(.cancelAction)
            .padding()
        }
        .frame(minWidth: 200)
    }
}

#Preview {
    InstanceChooseAccountSheet(sheetChooseAccount: .constant(true))
}
