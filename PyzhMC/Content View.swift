import SwiftUI

struct ContentView: View {
    @EnvironmentObject var launcherData: LauncherData
    
    private static let nullUuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    
    @State var searchTerm = ""
    @State var starredOnly = false
    @State var isSidebarHidden = false
    @State var selectedInstance: Instance? = nil
    @State var selectedAccount = ContentView.nullUuid
    @State var cachedAccounts: [AdaptedAccount] = []
    
    @State var sheetNewInstance = false
    @State var sheetDuplicateInstance = false
    @State var sheetDeleteInstance = false
    @State var sheetExportInstance = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search", text: $searchTerm)
                    .padding(.trailing, 8)
                    .padding(.leading, 10)
                    .padding([.top, .bottom], 9)
                    .textFieldStyle(.roundedBorder)
                
                List(selection: $selectedInstance) {
                    ForEach(launcherData.instances) { instance in
                        if (!starredOnly || instance.isStarred) && instance.matchesSearchTerm(searchTerm) {
                            InstanceNavigationLink(instance: instance, selectedInstance: $selectedInstance)
                                .tag(instance)
                                .padding(4)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .onMove { indices, newOffset in
                        launcherData.instances.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                .toolbar {
                    ToolbarItemGroup {
                        createSidebarToolbar()
                    }
                }
            }
            .sheet($sheetNewInstance) {
                NewInstanceView(showNewInstanceSheet: $sheetNewInstance)
            }
            .sheet($sheetDeleteInstance) {
                InstanceDeleteSheet(sheetDelete: $sheetDeleteInstance, selectedInstance: $selectedInstance, instanceToDelete: self.selectedInstance!)
            }
            .sheet($sheetDuplicateInstance) {
                InstanceDuplicationSheet(sheetDuplication: $sheetDuplicateInstance, instance: self.selectedInstance!)
            }
            .sheet($sheetExportInstance) {
                InstanceExportSheet(sheetExport: $sheetExportInstance, instance: self.selectedInstance!)
            }
            .onReceive(launcherData.$instances) { newValue in
                if let selectedInstance = self.selectedInstance {
                    if !newValue.contains(where: { $0 == selectedInstance }) {
                        self.selectedInstance = nil
                    }
                }
            }
            .navigationTitle("Instances")
            
            Text("Select an Instance")
                .largeTitle()
                .foregroundColor(.gray)
        }
        .bindInstanceFocusValue(selectedInstance)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                createTrailingToolbar()
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                createPrimaryToolbar()
            }
        }
    }
    
    @ViewBuilder
    func createSidebarToolbar() -> some View {
        Spacer()
        
        Button {
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        } label: {
            Image(systemName: "sidebar.leading")
        }
        
        Toggle(isOn: $starredOnly) {
            Image(systemName: starredOnly ? "star.fill" : "star")
        }
        .help("Show starred instances")
        
        Button {
            sheetNewInstance = true
        } label: {
            Image(systemName: "plus")
        }
        .onReceive(launcherData.$newInstanceRequested) { req in
            if req {
                sheetNewInstance = true
                launcherData.newInstanceRequested = false
            }
        }
    }
    
    @ViewBuilder
    func createPrimaryToolbar() -> some View {
        Button {
            self.sheetDeleteInstance = true
        } label: {
            Image(systemName: "trash")
        }
        .disabled(selectedInstance == nil)
        .help("Delete")
        
        Button {
            self.sheetDuplicateInstance = true
        } label: {
            Image(systemName: "doc.on.doc")
        }
        .disabled(selectedInstance == nil)
        .help("Duplicate")
        
        Button {
            self.sheetExportInstance = true
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .disabled(true)
        .help("Share or Export")
        
        Button {
            if launcherData.launchedInstances.contains(where: { $0.0 == selectedInstance! }) {
                launcherData.killRequestedInstances.append(selectedInstance!)
            } else {
                launcherData.launchRequestedInstances.append(selectedInstance!)
            }
        } label: {
            if let selectedInstance {
                if launcherData.launchedInstances.contains(where: { $0.0 == selectedInstance }) {
                    Image(systemName: "square.fill")
                } else {
                    Image(systemName: "arrowtriangle.forward.fill")
                }
            } else {
                Image(systemName: "arrowtriangle.forward.fill")
            }
        }
        .disabled(selectedInstance == nil)
        .help("launch")
        
        Button {
            if launcherData.editModeInstances.contains(where: { $0 == selectedInstance! }) {
                launcherData.editModeInstances.removeAll(where: { $0 == selectedInstance! })
            } else {
                launcherData.editModeInstances.append(self.selectedInstance!)
            }
        } label: {
            if let selectedInstance = self.selectedInstance {
                if launcherData.editModeInstances.contains(where: { $0 == selectedInstance }) {
                    Image(systemName: "checkmark")
                } else {
                    Image(systemName: "pencil")
                }
            } else {
                Image(systemName: "pencil")
            }
        }
        .disabled(selectedInstance == nil)
        .help("Edit")
    }
    
    @ViewBuilder
    func createTrailingToolbar() -> some View {
        Spacer()
        
        Picker("Account", selection: $selectedAccount) {
            Text("No account")
                .tag(ContentView.nullUuid)
            
            ForEach(self.cachedAccounts) { value in
                HStack(alignment: .center) {
                    AsyncImage(url: URL(string: "https://crafatar.com/avatars/" + value.id.uuidString + "?overlay&size=16"), scale: 1, content: { $0 }) {
                        Image("steve")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    
                    Text(value.username)
                }
                .background(.ultraThickMaterial)
                .padding()
                .tag(value.id)
            }
        }
        .frame(height: 40)
        .onAppear {
            self.selectedAccount = launcherData.accountManager.currentSelected ?? ContentView.nullUuid
            self.cachedAccounts = Array(launcherData.accountManager.accounts.values).map { .init(from: $0) }
        }
        .onReceive(launcherData.accountManager.$currentSelected) {
            self.selectedAccount = $0 ?? ContentView.nullUuid
        }
        .onChange(of: self.selectedAccount) { newValue in
            launcherData.accountManager.currentSelected = newValue == ContentView.nullUuid ? nil : newValue
            
            DispatchQueue.global(qos: .utility).async {
                launcherData.accountManager.saveThrow()
            }
        }
        .onReceive(launcherData.accountManager.$accounts) {
            self.cachedAccounts = Array($0.values).map { .init(from: $0) }
        }
        
        Button {
            launcherData.selectedPreferenceTab = .accounts
            if #available(macOS 13, *) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            } else {
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            }
        } label: {
            Image(systemName: "person.circle")
        }
        .help("Manage Accounts")
    }
}

extension NavigationView {
    @ViewBuilder
    func bindInstanceFocusValue(_ i: Instance?) -> some View {
        if #available(macOS 13, *) {
            self.focusedValue(\.selectedInstance, i)
        } else {
            self
        }
    }
}
