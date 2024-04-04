import SwiftUI

struct InstanceInterativeLogoView: View {
    @EnvironmentObject var launcherData: LauncherData
    @StateObject var instance: Instance
    
    @Binding var showLogoSheet: Bool
    @Binding var logoHovered: Bool
    
    var body: some View {
        let size = launcherData.globalPreferences.ui.compactInstanceLogo ? 64.0 : 128.0
        
        InstanceLogoView(instance: instance)
            .frame(width: size, height: size)
            .padding(.all, 20)
            .opacity(logoHovered ? 0.75 : 1)
            .onHover { value in
                withAnimation {
                    logoHovered = value
                }
            }
            .onTapGesture {
                showLogoSheet = true
            }
    }
}
