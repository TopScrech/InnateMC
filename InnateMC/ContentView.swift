import SwiftUI

struct ContentView: View {
    private static let nullUuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    @State var searchTerm = ""
    @State var starredOnly = false
    @EnvironmentObject var launcherData: LauncherData
    @State var isSidebarHidden = false
    @State var showNewInstanceSheet = false
    @State var selectedInstance: Instance? = nil
    @State var selectedAccount: UUID = ContentView.nullUuid
    @State var cachedAccounts: [AdaptedAccount] = []
    @State var showDuplicateInstanceSheet = false
    @State var showDeleteInstanceSheet = false
    @State var showExportInstanceSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField(i18n("search"), text: $searchTerm)
                    .padding(.trailing, 8.0)
                    .padding(.leading, 10.0)
                    .padding([.top, .bottom], 9.0)
                    .textFieldStyle(.roundedBorder)
                
                List(selection: $selectedInstance) {
                    ForEach(launcherData.instances) { instance in
                        if (!starredOnly || instance.isStarred) && instance.matchesSearchTerm(searchTerm) {
                            InstanceNavigationLink(instance: instance, selectedInstance: $selectedInstance)
                                .tag(instance)
                                .padding(.all, 4)
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
            .sheet($showNewInstanceSheet) {
                NewInstanceView(showNewInstanceSheet: $showNewInstanceSheet)
            }
            .sheet($showDeleteInstanceSheet) {
                InstanceDeleteSheet(showDeleteSheet: $showDeleteInstanceSheet, selectedInstance: $selectedInstance, instanceToDelete: self.selectedInstance!)
            }
            .sheet($showDuplicateInstanceSheet) {
                InstanceDuplicationSheet(showDuplicationSheet: $showDuplicateInstanceSheet, instance: self.selectedInstance!)
            }
            .sheet($showExportInstanceSheet) {
                InstanceExportSheet(showExportSheet: $showExportInstanceSheet, instance: self.selectedInstance!)
            }
            .onReceive(launcherData.$instances) { newValue in
                if let selectedInstance = self.selectedInstance {
                    if !newValue.contains(where: { $0 == selectedInstance }) {
                        self.selectedInstance = nil
                    }
                }
            }
            .navigationTitle(i18n("instances_title"))
            
            Text(i18n("select_an_instance"))
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
        .help(i18n("show_only_starred"))
        
        Button {
            showNewInstanceSheet = true
        } label: {
            Image(systemName: "plus")
        }
        .onReceive(launcherData.$newInstanceRequested) { req in
            if req {
                showNewInstanceSheet = true
                launcherData.newInstanceRequested = false
            }
        }
    }
    
    @ViewBuilder
    func createPrimaryToolbar() -> some View {
        Button {
            self.showDeleteInstanceSheet = true
        } label: {
            Image(systemName: "trash")
        }
        .disabled(selectedInstance == nil)
        .help(i18n("delete"))
        
        Button {
            self.showDuplicateInstanceSheet = true
        } label: {
            Image(systemName: "doc.on.doc")
        }
        .disabled(selectedInstance == nil)
        .help(i18n("duplicate"))
        
        Button {
            self.showExportInstanceSheet = true
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .disabled(true)
        .help(i18n("share_or_export"))
        
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
        .help(i18n("launch"))
        
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
        .help(i18n("edit"))
    }
    
    @ViewBuilder
    func createTrailingToolbar() -> some View {
        Spacer()
        
        Picker(i18n("account"), selection: $selectedAccount) {
            Text(i18n("no_account_selected"))
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
                .padding(.all)
                .tag(value.id)
            }
        }
        .frame(height: 40)
        .onAppear {
            self.selectedAccount = launcherData.accountManager.currentSelected ?? ContentView.nullUuid
            self.cachedAccounts = Array(launcherData.accountManager.accounts.values).map({ AdaptedAccount(from: $0)})
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
            self.cachedAccounts = Array($0.values).map({ AdaptedAccount(from: $0)})
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
        .help("manage_accounts")
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
