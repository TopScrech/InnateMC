import SwiftUI

struct NewVanillaInstanceView: View {
    @EnvironmentObject var launcherData: LauncherData
    
    @AppStorage("newVanillaInstance.cachedName") var name = NSLocalizedString("New Instance", comment: "New Instance")
    @AppStorage("newVanillaInstance.cachedVersion") var cachedVersionId = ""
    
    @Binding var sheetNewInstance: Bool
    
    @State var versionManifest: [PartialVersion] = []
    @State var showSnapshots = false
    @State var showBeta = false
    @State var showAlpha = false
    @State var selectedVersion = PartialVersion.createBlank()
    @State var versions: [PartialVersion] = []
    
    @State var popoverNoName = false
    @State var popoverDuplicateName = false
    @State var popoverInvalidVersion = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Form {
                TextField("Name", text: $name).frame(width: 400, height: nil, alignment: .leading)
                    .textFieldStyle(.roundedBorder)
                    .popover(isPresented: $popoverNoName, arrowEdge: .bottom) {
                        Text("Enter a name")
                            .padding()
                    }
                    .popover(isPresented: $popoverDuplicateName, arrowEdge: .bottom) {
                        // TODO: implement
                        Text("Enter a unique name")
                            .padding()
                    }
                Picker("Version", selection: $selectedVersion) {
                    ForEach(versions) { ver in
                        Text(ver.version)
                            .tag(ver)
                    }
                }
                .popover(isPresented: $popoverInvalidVersion, arrowEdge: .bottom) {
                    Text("Choose a valid version")
                        .padding()
                }
                
                Toggle("Show snapshots", isOn: $showSnapshots)
                
                Toggle("Show old beta", isOn: $showBeta)
                
                Toggle("Show old alpha", isOn: $showAlpha)
            }
            .padding()
            
            HStack {
                Spacer()
                
                HStack {
                    Button("Cancel") {
                        sheetNewInstance = false
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Button("Done") {
                        let trimmedName = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if trimmedName.isEmpty { // TODO: also check for spaces
                            self.popoverNoName = true
                            return
                        }
                        
                        if launcherData.instances.map({ $0.name }).contains(where: { $0.lowercased() == trimmedName.lowercased()}) {
                            self.popoverDuplicateName = true
                            return
                        }
                        
                        if !self.versionManifest.contains(where: { $0 == self.selectedVersion }) {
                            self.popoverInvalidVersion = true
                            
                            return
                        }
                        
                        self.popoverNoName = false
                        self.popoverDuplicateName = false
                        self.popoverInvalidVersion = false
                        
                        let instance = VanillaInstanceCreator(name: trimmedName, versionUrl: URL(string: self.selectedVersion.url)!, sha1: self.selectedVersion.sha1, notes: nil, data: self.launcherData)
                        do {
                            self.launcherData.instances.append(try instance.install())
                            self.name = NSLocalizedString("New Instance", comment: "New Instance")
                            self.cachedVersionId = ""
                            self.sheetNewInstance = false
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
    NewVanillaInstanceView(sheetNewInstance: .constant(true))
}
