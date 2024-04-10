import SwiftUI

struct InstanceView: View {
    @StateObject var editingVM = InstanceEditingVM()
    @StateObject var instance: Instance
    @EnvironmentObject var launcherData: LauncherData
    
    @State var disabled = false
    @State var starHovered = false
    @State var logoHovered = false
    @State var launchError: LaunchError? = nil
    @State var downloadSession: URLSession? = nil
    @State var downloadMessage: LocalizedStringKey = "Downloading Libraries"
    @State var downloadProgress = TaskProgress(current: 0, total: 1)
    @State var progress: Float = 0
    @State var launchedInstanceProcess: InstanceProcess? = nil
    @State var indeterminateProgress = false
    
    @State var popoverNoName = false
    @State var popoverDuplicate = false
    @State var sheetError = false
    @State var sheetPreLaunch = false
    @State var sheetChooseAccount = false
    @State var sheetLogo = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    InstanceInterativeLogoView(instance: instance, sheetLogo: $sheetLogo, logoHovered: $logoHovered)
                    
                    VStack {
                        HStack {
                            InstanceTitleView(editingVM: editingVM, instance: instance, showNoNamePopover: $popoverNoName, showDuplicatePopover: $popoverDuplicate, starHovered: $starHovered)
                            
                            Spacer()
                        }
                        
                        HStack {
                            InstanceSynopsisView(editingVM: editingVM, instance: instance)
                            
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                }
                .sheet($sheetLogo) {
                    InstanceLogoSheet(instance: instance, sheetLogo: $sheetLogo)
                }
                
                HStack {
                    InstanceNotesView(editingVM: editingVM, instance: instance)
                    
                    Spacer()
                }
                
                Spacer()
                
                TabView {
                    InstanceConsoleView(instance: instance, launchedInstanceProcess: $launchedInstanceProcess)
                        .tabItem {
                            Label("Console", systemImage: "bolt")
                        }
                    
                    InstanceModsView(instance: instance)
                        .tabItem {
                            Label("Mods", systemImage: "plus.square.on.square")
                        }
                    
                    InstanceScreenshotsView(instance: instance)
                        .tabItem {
                            Label("Screenshots", systemImage: "plus.square.on.square")
                        }
                    
                    InstanceWorldsView(instance: instance)
                        .tabItem {
                            Label("Worlds", systemImage: "plus.square.on.square")
                        }
                    
                    InstanceRuntimeView(instance: instance)
                        .tabItem {
                            Label("Settings", systemImage: "bolt")
                        }
                }
                .padding(4)
            }
            .padding(6)
            .onAppear {
                launcherData.launchRequestedInstances.removeAll(where: { $0 == self.instance })
                launchedInstanceProcess = launcherData.launchedInstances[instance]
                instance.loadScreenshotsAsync()
            }
            .sheet($sheetError) {
                LaunchErrorSheet(launchError: $launchError)
            }
            .sheet($sheetPreLaunch, content: createPrelaunchSheet)
            .sheet($sheetChooseAccount) {
                InstanceChooseAccountSheet()
            }
            .onReceive(launcherData.$launchedInstances) { value in
                launchedInstanceProcess = launcherData.launchedInstances[instance]
            }
            .onReceive(launcherData.$launchRequestedInstances) { value in
                if value.contains(where: { $0 == self.instance }) {
                    if launcherData.accountManager.currentSelected != nil {
                        sheetPreLaunch = true
                        downloadProgress.cancelled = false
                    } else {
                        sheetChooseAccount = true
                    }
                    
                    launcherData.launchRequestedInstances.removeAll(where: { $0 == self.instance })
                }
            }
            .onReceive(launcherData.$editModeInstances) { value in
                if value.contains(where: { $0 == self.instance}) {
                    self.editingVM.start(from: self.instance)
                } else if self.editingVM.inEditMode {
                    self.editingVM.commit(to: self.instance, showNoNamePopover: $popoverNoName, showDuplicateNamePopover: $popoverDuplicate, data: self.launcherData)
                }
            }
            .onReceive(launcherData.$killRequestedInstances) { value in
                if value.contains(where: { $0 == self.instance})  {
                    kill(launchedInstanceProcess!.process.processIdentifier, SIGKILL)
                    
                    launcherData.killRequestedInstances.removeAll {
                        $0 == self.instance
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func createPrelaunchSheet() -> some View {
        VStack {
            HStack {
                Spacer()
                
                Text(downloadMessage)
                
                Spacer()
            }
            .padding()
            
            if indeterminateProgress {
                ProgressView()
                    .progressViewStyle(.linear)
            } else {
                ProgressView(value: progress)
            }
            
            Button("Abort") {
                logger.info("Aborting instance launch")
                self.downloadSession?.invalidateAndCancel()
                sheetPreLaunch = false
                self.downloadProgress.cancelled = true
                self.downloadProgress = TaskProgress(current: 0, total: 1)
            }
            .onReceive(downloadProgress.$current) {
                progress = Float($0) / Float(downloadProgress.total)
            }
            .padding()
        }
        .onAppear {
            onPrelaunchSheetAppear()
        }
        .padding(10)
    }
    
    func onPrelaunchSheetAppear() {
        logger.info("Preparing to launch \(self.instance.name)")
        self.indeterminateProgress = false
        self.downloadProgress.cancelled = false
        
        downloadMessage = "Downloading Libraries"
        logger.info("Downloading libraries")
        
        downloadSession = instance.downloadLibs(progress: downloadProgress) {
            downloadMessage = "Downloading Assets"
            logger.info("Downloading assets")
            
            downloadSession = instance.downloadAssets(progress: downloadProgress) {
                downloadMessage = "Extracting Natives"
                logger.info("Extracting natives")
                
                downloadProgress.callback = {
                    if !downloadProgress.cancelled {
                        self.indeterminateProgress = true
                        downloadMessage = "Authenticating with Minecraft"
                        logger.info("Fetching access token")
                        
                        Task(priority: .high) {
                            do {
                                let accessToken = try await launcherData.accountManager.selectedAccount.createAccessToken()
                                
                                DispatchQueue.main.async {
                                    withAnimation {
                                        let process = InstanceProcess(instance: instance, account: launcherData.accountManager.selectedAccount, accessToken: accessToken)
                                        
                                        launcherData.launchedInstances[instance] = process
                                        launchedInstanceProcess = process
                                        sheetPreLaunch = false
                                    }
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    onPrelaunchError(.accessTokenFetchError(error: error))
                                }
                            }
                        }
                    }
                    
                    downloadProgress.callback = {}
                }
                
                instance.extractNatives(progress: downloadProgress)
            } onError: {
                onPrelaunchError($0)
            }
        } onError: {
            onPrelaunchError($0)
        }
    }
    
    @MainActor
    func onPrelaunchError(_ error: LaunchError) {
        if sheetError {
            logger.debug("Suppressed error during prelaunch: \(error.localizedDescription)")
            
            if let sup = error.cause {
                logger.debug("Cause: \(sup.localizedDescription)")
            }
            
            return
        }
        
        logger.error("Caught error during prelaunch", error: error)
        
        ErrorTracker.instance.error(error: error, description: "Caught error during prelaunch")
        
        if let cause = error.cause {
            logger.error("Cause", error: cause)
            
            ErrorTracker.instance.error(error: error, description: "Causative error during prelaunch")
        }
        
        sheetPreLaunch = false
        sheetError = true
        downloadProgress.cancelled = true
        launchError = error
    }
}
