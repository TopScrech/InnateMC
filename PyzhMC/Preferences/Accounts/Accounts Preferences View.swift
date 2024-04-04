import SwiftUI

struct AccountsPreferencesView: View {
    @StateObject var msAccountVM = MicrosoftAccountVM()
    @EnvironmentObject var launcherData: LauncherData
    
    @State var cachedAccounts: [UUID: any MinecraftAccount] = [:]
    @State var cachedAccountsOnly: [AdaptedAccount] = []
    @State var selectedAccountIds: Set<UUID> = []
    
    @State var sheetAddOffline = false
    
    var body: some View {
        VStack {
            Table(cachedAccountsOnly, selection: $selectedAccountIds) {
                TableColumn("Name", value: \.username)
                
                TableColumn("Type", value: \.type.rawValue)
                    .width(max: 100)
            }
            
            HStack {
                Spacer()
                
                Button("Add Offline Account") {
                    sheetAddOffline = true
                }
                .padding()
                
                Button("Add Microsoft Account") {
                    self.msAccountVM.prepareAndOpenSheet(launcherData: self.launcherData)
                }
                .padding()
                
                Button("Delete Selected") {
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
        .onReceive(msAccountVM.$sheetMicrosoftAccount) {
            if !$0 {
                launcherData.accountManager.msAccountVM = nil
            }
        }
        .sheet($sheetAddOffline) {
            AddOfflineAccountView(showSheet: $sheetAddOffline) {
                let acc = OfflineAccount.createFromUsername($0)
                self.launcherData.accountManager.accounts[acc.id] = acc
                
                DispatchQueue.global(qos: .utility).async {
                    self.launcherData.accountManager.saveThrow() // TODO: handle error
                }
            }
        }
        .sheet($msAccountVM.sheetMicrosoftAccount) {
            HStack {
                if msAccountVM.error == .noError {
                    Text(msAccountVM.message)
                        .padding()
                } else {
                    VStack {
                        Text(msAccountVM.error.localizedDescription)
                            .padding()
                        
                        Button("Close") {
                            msAccountVM.closeSheet()
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
