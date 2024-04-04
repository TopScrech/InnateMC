import SwiftUI

struct LaunchErrorSheet: View {
    @Binding var launchError: LaunchError?
    @Binding var showErrorSheet: Bool
    
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
                
                Button(i18n("close")) {
                    self.showErrorSheet = false
                }
                .keyboardShortcut(.cancelAction)
                .padding()
            }
        }
    }
}
