import SwiftUI

struct AccountsPreferencesView: View {
    @EnvironmentObject var launcherData: LauncherData
    
    @State var showAddOfflineSheet = false
    @StateObject var msAccountViewModel: MicrosoftAccountViewModel = .init()
    @State var cachedAccounts: [UUID: any MinecraftAccount] = [:]
    @State var cachedAccountsOnly: [AdaptedAccount] = []
    @State var selectedAccountIds: Set<UUID> = []
    
    var body: some View {
        VStack {
            Table(cachedAccountsOnly, selection: $selectedAccountIds) {
                TableColumn(i18n("name"), value: \.username)
                
                TableColumn(i18n("type"), value: \.type.rawValue)
                    .width(max: 100)
            }
            
            HStack {
                Spacer()
                
                Button(i18n("add_offline")) {
                    self.showAddOfflineSheet = true
                }
                .padding()
                
                Button(i18n("add_microsoft")) {
                    self.msAccountViewModel.prepareAndOpenSheet(launcherData: self.launcherData)
                }
                .padding()
                
                Button(i18n("delete_selected")) {
                    for id in selectedAccountIds {
                        self.launcherData.accountManager.accounts.removeValue(forKey: id)
                    }
                    self.selectedAccountIds = []
                    
                    DispatchQueue.global(qos: .utility).async {
                        self.launcherData.accountManager.saveThrow() // TODO: handle error
                    }
                }
                .disabled(self.selectedAccountIds.isEmpty)
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            self.cachedAccounts = launcherData.accountManager.accounts
            self.cachedAccountsOnly = Array(self.cachedAccounts.values).map({ AdaptedAccount(from: $0)})
        }
        .onReceive(launcherData.accountManager.$accounts) {
            self.cachedAccounts = $0
            self.cachedAccountsOnly = Array($0.values).map({ AdaptedAccount(from: $0)})
        }
        .onReceive(msAccountViewModel.$showMicrosoftAccountSheet) {
            if !$0 {
                launcherData.accountManager.msAccountViewModel = nil
            }
        }
        .sheet($showAddOfflineSheet) {
            AddOfflineAccountView(showSheet: $showAddOfflineSheet) {
                let acc = OfflineAccount.createFromUsername($0)
                self.launcherData.accountManager.accounts[acc.id] = acc
                DispatchQueue.global(qos: .utility).async {
                    self.launcherData.accountManager.saveThrow() // TODO: handle error
                }
            }
        }
        .sheet($msAccountViewModel.showMicrosoftAccountSheet) {
            HStack {
                if msAccountViewModel.error == .noError {
                    VStack {
                        Text(msAccountViewModel.message)
                    }
                    .padding()
                } else {
                    VStack {
                        Text(msAccountViewModel.error.localizedDescription)
                            .padding()
                        
                        Button("Close") {
                            msAccountViewModel.closeSheet()
                        }
                        .padding()
                    }
                    .padding()
                }
            }
            .frame(idealWidth: 400)
        }
    }
}

#Preview {
    AccountsPreferencesView()
}

class AdaptedAccount: Identifiable {
    var id: UUID
    var username: String
    var type: MinecraftAccountType
    
    init(from acc: any MinecraftAccount) {
        self.id = acc.id
        self.username = acc.username
        self.type = acc.type
    }
}
