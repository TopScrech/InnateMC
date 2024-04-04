import SwiftUI

struct UiPreferencesView: View {
    @EnvironmentObject var launcherData: LauncherData
    
    var body: some View {
        Form {
            Toggle(i18n("compact_instance_list"), isOn: $launcherData.globalPreferences.ui.compactList)
            
            Toggle(i18n("compact_instance_logo"), isOn: $launcherData.globalPreferences.ui.compactInstanceLogo)
        }
        .padding(16)
    }
}

#Preview {
    UiPreferencesView()
}
