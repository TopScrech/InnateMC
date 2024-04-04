import SwiftUI

struct InstanceRuntimeView: View {
    @EnvironmentObject var launcherData: LauncherData
    @StateObject var instance: Instance
    
    @State var valid = false
    @State var selectedJava = SavedJavaInstallation.systemDefault
    
    var body: some View {
        VStack {
            Form {
                Toggle(isOn: $instance.preferences.runtime.valid) {
                    Text(i18n("Override default runtime settings"))
                }
                .padding(.bottom, 5)
                
                Picker(i18n("java"), selection: $selectedJava) {
                    PickableJavaVersion(installation: SavedJavaInstallation.systemDefault)
                    
                    ForEach(launcherData.javaInstallations) {
                        PickableJavaVersion(installation: $0)
                    }
                }
                .disabled(!valid)
                
                TextField(i18n("default_min_mem"), value: $instance.preferences.runtime.minMemory, formatter: NumberFormatter())
                    .textFieldStyle(.roundedBorder)
                    .disabled(!valid)
                
                TextField(i18n("default_max_mem"), value: $instance.preferences.runtime.maxMemory, formatter: NumberFormatter())
                    .textFieldStyle(.roundedBorder)
                    .disabled(!valid)
                
                TextField(i18n("default_java_args"), text: $instance.preferences.runtime.javaArgs)
                    .textFieldStyle(.roundedBorder)
                    .disabled(!valid)
            }
            .padding(.all, 16)
            
            Spacer()
        }
        .onAppear {
            valid = instance.preferences.runtime.valid
            selectedJava = instance.preferences.runtime.defaultJava
        }
        .onChange(of: selectedJava) { newValue in
            instance.preferences.runtime.defaultJava = newValue
        }
        .onReceive(instance.preferences.runtime.$valid) {
            logger.debug("Changed runtime preferences validity for \(instance.name) to \($0)")
            
            if !$0 && valid {
                instance.preferences.runtime = .init(launcherData.globalPreferences.runtime).invalidate()
                selectedJava = launcherData.globalPreferences.runtime.defaultJava
            }
            
            valid = $0
        }
    }
}
