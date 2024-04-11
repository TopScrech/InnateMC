import SwiftUI

struct AccountsPreferencesView: View {
    @StateObject private var msAccountVM = MicrosoftAccountVM()
    @EnvironmentObject private var launcherData: LauncherData
    
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
                    msAccountVM.prepareAndOpenSheet(launcherData: self.launcherData)
                }
                .padding()
                
                Button("Delete Selected") {
                    for id in selectedAccountIds {
                        launcherData.accountManager.accounts.removeValue(forKey: id)
                    }
                    
                    selectedAccountIds = []
                    
                    DispatchQueue.global(qos: .utility).async {
                        launcherData.accountManager.saveThrow() // TODO: handle error
                    }
                }
                .disabled(selectedAccountIds.isEmpty)
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            cachedAccounts = launcherData.accountManager.accounts
            
            cachedAccountsOnly = Array(cachedAccounts.values).map { AdaptedAccount(from: $0)
            }
        }
        .onReceive(launcherData.accountManager.$accounts) {
            cachedAccounts = $0
            
            cachedAccountsOnly = Array($0.values).map {
                AdaptedAccount(from: $0)
            }
        }
        .onReceive(msAccountVM.$sheetMicrosoftAccount) {
            if !$0 {
                launcherData.accountManager.msAccountVM = nil
            }
        }
        .sheet($sheetAddOffline) {
            AddOfflineAccountView {
                let acc = OfflineAccount.createFromUsername($0)
                launcherData.accountManager.accounts[acc.id] = acc
                
                DispatchQueue.global(qos: .utility).async {
                    launcherData.accountManager.saveThrow() // TODO: handle error
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
