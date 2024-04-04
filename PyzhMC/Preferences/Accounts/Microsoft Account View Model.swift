import SwiftUI

class MicrosoftAccountVM: ObservableObject {
    @Published var message: LocalizedStringKey = "Authenticating with Microsoft"
    @Published var error: MicrosoftAuthError = .noError
    
    @Published var sheetMicrosoftAccount = false
    
    @MainActor func error(_ error: MicrosoftAuthError) {
        ErrorTracker.instance.error(
            error: error,
            description: NSLocalizedString("Caught error while adding Microsoft account", comment: "")
        )
        
        self.error = error
    }
    
    @MainActor func prepareAndOpenSheet(launcherData: LauncherData) {
        self.sheetMicrosoftAccount = true
        launcherData.accountManager.msAccountVM = self
        launcherData.accountManager.createAuthWindow().showWindow(PyzhMCApp.self)
    }
    
    @MainActor func closeSheet() {
        self.sheetMicrosoftAccount = false
        self.error(.noError)
        self.message = "Authenticating with Microsoft"
    }
    
    @MainActor func setAuthWithXboxLive() {
        self.message = "Authenticating with Xbox Live"
    }
    
    @MainActor func setAuthWithXboxXSTS() {
        self.message = "Authenticating with Xbox XSTS"
    }
    
    @MainActor func setAuthWithMinecraft() {
        self.message = "Authenticating with Minecraft"
    }
    
    @MainActor func setFetchingProfile() {
        self.message = "Fetching Profile"
    }
}
