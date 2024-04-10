import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var launcherData: LauncherData
    
    var body: some View {
        TabView(selection: $launcherData.selectedPreferenceTab) {
            RuntimePreferencesView()
                .tabItem {
                    Label("Runtime", systemImage: "cup.and.saucer")
                }
                .tag(SelectedPreferenceTab.runtime)
            
            AccountsPreferencesView()
                .tabItem {
                    Label("Accounts", systemImage: "person.circle")
                }
                .tag(SelectedPreferenceTab.accounts)
            
            UiPreferencesView()
                .tag(SelectedPreferenceTab.ui)
                .tabItem {
                    Label("UI", systemImage: "paintbrush.pointed")
                }
            
            MiscPreferencesView()
                .tabItem {
                    Label("Misc", systemImage: "slider.horizontal.3")
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
