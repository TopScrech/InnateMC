import SwiftUI

struct LaunchErrorSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var launchError: LaunchError?
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    
                    VStack {
                        if let launchError {
                            Text(launchError.localizedDescription)
                            
                            if let err = launchError.cause {
                                Text(err.localizedDescription)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                .padding()
            }
        }
    }
}
