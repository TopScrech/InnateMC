import SwiftUI

struct MiscPreferencesView: View {
    @AppStorage("developerMode") var developerMode = true
    
    var body: some View {
        Form {
            Toggle(i18n("developer_mode"), isOn: $developerMode)
        }
        .padding(.all, 16.0)
    }
}

#Preview {
    MiscPreferencesView()
}
