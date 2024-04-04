import SwiftUI

struct LaunchErrorSheet: View {
    @Binding var launchError: LaunchError?
    @Binding var sheetError: Bool
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    
                    VStack {
                        if let launchError = self.launchError {
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
                    sheetError = false
                }
                .keyboardShortcut(.cancelAction)
                .padding()
            }
        }
    }
}
