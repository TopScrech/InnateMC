import SwiftUI

class MicrosoftAccountViewModel: ObservableObject {
    @Published var showMicrosoftAccountSheet = false
    @Published var message: LocalizedStringKey = i18n("authenticating_with_microsoft")
    @Published var error: MicrosoftAuthError = .noError
    
    @MainActor func error(_ error: MicrosoftAuthError) {
        ErrorTracker.instance.error(error: error, description: NSLocalizedString("error_during_microsoft_add", comment: "Caught error while adding microsoft account"))
        self.error = error
    }
    
    @MainActor func prepareAndOpenSheet(launcherData: LauncherData) {
        self.showMicrosoftAccountSheet = true
        launcherData.accountManager.msAccountViewModel = self
        launcherData.accountManager.createAuthWindow().showWindow(InnateMCApp.self)
    }
    
    @MainActor func closeSheet() {
        self.showMicrosoftAccountSheet = false
        self.error(.noError)
        self.message = i18n("authenticating_with_microsoft")
    }
    
    @MainActor func setAuthWithXboxLive() {
        self.message = i18n("authenticating_with_xbox_live")
    }
    
    @MainActor func setAuthWithXboxXSTS() {
        self.message = i18n("authenticating_with_xbox_xsts")
    }
    
    @MainActor func setAuthWithMinecraft() {
        self.message = i18n("authenticating_with_minecraft")
    }
    
    @MainActor func setFetchingProfile() {
        self.message = i18n("fetching_profile")
    }
}
