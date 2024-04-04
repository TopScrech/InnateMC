import SwiftUI

struct AddOfflineAccountView: View {
    @Binding var showSheet: Bool
    @State var onCommit: (String) -> Void
    
    @State var username = ""
    
    @State var popoverBlank = false
    
    var body: some View {
        VStack {
            Form {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .popover(isPresented: $popoverBlank, arrowEdge: .bottom) {
                        Text("Enter a username")
                            .padding()
                    }
                    .padding()
            }
            HStack {
                if !isValidMinecraftUsername(self.username) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    
                    Text("Invalid username")
                }
                
                Spacer()
                
                Button("Cancel") {
                    showSheet = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Done") {
                    if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        popoverBlank = true
                    } else {
                        onCommit(username)
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
