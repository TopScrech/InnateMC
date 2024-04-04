import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var launcherData: LauncherData
    
    var body: some View {
        TabView(selection: $launcherData.selectedPreferenceTab) {
            RuntimePreferencesView()
                .tabItem {
                    Label(i18n("runtime"), systemImage: "cup.and.saucer")
                }
                .tag(SelectedPreferenceTab.runtime)
            
            AccountsPreferencesView()
                .tabItem {
                    Label(i18n("accounts"), systemImage: "person.circle")
                }
                .tag(SelectedPreferenceTab.accounts)
            
            UiPreferencesView()
                .tag(SelectedPreferenceTab.ui)
                .tabItem {
                    Label(i18n("user_interface"), systemImage: "paintbrush.pointed")
                }
            
            MiscPreferencesView()
                .tabItem {
                    Label(i18n("misc"), systemImage: "slider.horizontal.3")
                }
                .tag(SelectedPreferenceTab.misc)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.launcherData.initializePreferenceListenerIfNot()
            }
        }
    }
}
