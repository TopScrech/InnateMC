import SwiftUI

struct MiscPreferencesView: View {
    @AppStorage("developerMode") var developerMode = true
    
    var body: some View {
        Form {
            Toggle(i18n("developer_mode"), isOn: $developerMode)
        }
        .padding(16)
    }
}

#Preview {
    MiscPreferencesView()
}
