import SwiftUI

struct AddOfflineAccountView: View {
    @State var username = ""
    @State var showBlankPopover = false
    @Binding var showSheet: Bool
    @State var onCommit: (String) -> Void
    
    var body: some View {
        VStack {
            Form {
                TextField(i18n("username"), text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .popover(isPresented: $showBlankPopover, arrowEdge: .bottom) {
                        Text(i18n("enter_a_username"))
                            .padding()
                    }
                    .padding()
            }
            HStack {
                if !isValidMinecraftUsername(self.username) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    
                    Text(i18n("invalid_username"))
                }
                
                Spacer()
                
                Button(i18n("cancel")) {
                    showSheet = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button(i18n("done")) {
                    if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        showBlankPopover = true
                    } else {
                        onCommit(self.username)
                        showSheet = false
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(maxWidth: 350)
    }
    
    private func isValidMinecraftUsername(_ username: String) -> Bool {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        let disallowedWords = ["minecraft", "mojang", "admin", "administrator"]
        
        if username.count < 3 || username.count > 16 {
            return false
        }
        
        if !username.allSatisfy({ allowedCharacters.contains(UnicodeScalar(String($0))!) }) {
            return false
        }
        
        let lowercaseUsername = username.lowercased()
        
        if disallowedWords.contains(where: { lowercaseUsername.contains($0) }) {
            return false
        }
        
        return true
    }
}
