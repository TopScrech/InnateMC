import SwiftUI

struct NewVanillaInstanceView: View {
    @EnvironmentObject var launcherData: LauncherData
    
    @AppStorage("newVanillaInstance.cachedName") var name = NSLocalizedString("new_instance_default", comment: "New Instance")
    @AppStorage("newVanillaInstance.cachedVersion") var cachedVersionId = ""
    
    @Binding var showNewInstanceSheet: Bool
    
    @State var versionManifest: [PartialVersion] = []
    @State var showSnapshots = false
    @State var showBeta = false
    @State var showAlpha = false
    @State var selectedVersion = PartialVersion.createBlank()
    
    @State var versions: [PartialVersion] = []
    @State var showNoNamePopover = false
    @State var showDuplicateNamePopover = false
    @State var showInvalidVersionPopover = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Form {
                TextField(i18n("name"), text: $name).frame(width: 400, height: nil, alignment: .leading).textFieldStyle(RoundedBorderTextFieldStyle())
                    .popover(isPresented: $showNoNamePopover, arrowEdge: .bottom) {
                        Text(i18n("enter_a_name"))
                            .padding()
                    }
                    .popover(isPresented: $showDuplicateNamePopover, arrowEdge: .bottom) {
                        // TODO: implement
                        Text(i18n("enter_unique_name"))
                            .padding()
                    }
                Picker(i18n("version"), selection: $selectedVersion) {
                    ForEach(self.versions) { ver in
                        Text(ver.version)
                            .tag(ver)
                    }
                }
                .popover(isPresented: $showInvalidVersionPopover, arrowEdge: .bottom) {
                    Text(i18n("choose_valid_version"))
                        .padding()
                }
                
                Toggle(i18n("show_snapshots"), isOn: $showSnapshots)
                
                Toggle(i18n("show_old_beta"), isOn: $showBeta)
                
                Toggle(i18n("show_old_alpha"), isOn: $showAlpha)
            }
            .padding()
            
            HStack {
                Spacer()
                
                HStack {
                    Button(i18n("cancel")) {
                        showNewInstanceSheet = false
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Button(i18n("done")) {
                        let trimmedName = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if trimmedName.isEmpty { // TODO: also check for spaces
                            self.showNoNamePopover = true
                            return
                        }
                        
                        if launcherData.instances.map({ $0.name }).contains(where: { $0.lowercased() == trimmedName.lowercased()}) {
                            self.showDuplicateNamePopover = true
                            return
                        }
                        
                        if !self.versionManifest.contains(where: { $0 == self.selectedVersion }) {
                            self.showInvalidVersionPopover = true
                            
                            return
                        }
                        
                        self.showNoNamePopover = false
                        self.showDuplicateNamePopover = false
                        self.showInvalidVersionPopover = false
                        
                        let instance = VanillaInstanceCreator(name: trimmedName, versionUrl: URL(string: self.selectedVersion.url)!, sha1: self.selectedVersion.sha1, notes: nil, data: self.launcherData)
                        do {
                            self.launcherData.instances.append(try instance.install())
                            self.name = NSLocalizedString("new_instance_default", comment: "New Instance")
                            self.cachedVersionId = ""
                            self.showNewInstanceSheet = false
                        } catch {
                            ErrorTracker.instance.error(error: error, description: "Error creating instance")
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                }
                .padding([.trailing, .bottom])
            }
        }
        .onAppear {
            self.versionManifest = self.launcherData.versionManifest
            recomputeVersions()
        }
        .onReceive(self.launcherData.$versionManifest) {
            self.versionManifest = $0
            recomputeVersions()
        }
        .onChange(of: showAlpha) { _ in
            recomputeVersions()
        }
        .onChange(of: showBeta) { _ in
            recomputeVersions()
        }
        .onChange(of: showSnapshots) { _ in
            recomputeVersions()
        }
        .onChange(of: selectedVersion) { _ in
            self.cachedVersionId = self.selectedVersion.version
        }
    }
    
    func recomputeVersions() {
        if versionManifest.isEmpty {
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let newVersions = self.versionManifest
                .filter { version in
                    return version.type == "old_alpha" && showAlpha ||
                    version.type == "old_beta" && showBeta ||
                    version.type == "snapshot" && showSnapshots ||
                    version.type == "release"
                }
            
            let notContained = !newVersions.contains(self.selectedVersion)
            
            DispatchQueue.main.async {
                self.versions = newVersions
                
                if let cached = self.versions.filter({ $0.version == self.cachedVersionId }).first {
                    self.selectedVersion = cached
                } else if notContained {
                    self.selectedVersion = newVersions.first!
                }
            }
        }
    }
}

#Preview {
    NewVanillaInstanceView(showNewInstanceSheet: .constant(true))
}
