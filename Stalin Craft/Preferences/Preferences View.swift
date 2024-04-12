import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var launcherData: LauncherData
    
    var body: some View {
        TabView(selection: $launcherData.selectedPreferenceTab) {
            RuntimePreferencesView()
                .tag(PreferenceTab.runtime)
                .tabItem {
                    Label("Runtime", systemImage: "cup.and.saucer")
                }
            
            AccountsPreferencesView()
                .tag(PreferenceTab.accounts)
                .tabItem {
                    Label("Accounts", systemImage: "person.circle")
                }
            
            ModToolsList()
                .tag(PreferenceTab.modtools)
                .tabItem {
                    Label("Mod Tools", systemImage: "hammer")
                }
            
            UiPreferencesView()
                .tag(PreferenceTab.ui)
                .tabItem {
                    Label("UI", systemImage: "paintbrush.pointed")
                }
            
            MiscPreferencesView()
                .tag(PreferenceTab.misc)
                .tabItem {
                    Label("Misc", systemImage: "slider.horizontal.3")
                }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.launcherData.initializePreferenceListenerIfNot()
            }
        }
    }
}
