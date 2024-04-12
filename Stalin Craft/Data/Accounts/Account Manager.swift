import Foundation
import Swifter

class AccountManager: ObservableObject {
    static let accountsPath = try! FileHandler.getOrCreateFolder().appendingPathComponent("Accounts.plist")
    static let plistEncoder = PropertyListEncoder()
    
    let server: HttpServer
    var serverThread: DispatchQueue?
    
    @Published var currentSelected: UUID? = nil
    @Published var accounts: [UUID: any MinecraftAccount] = [:]
    
    var selectedAccount: any MinecraftAccount {
        accounts[currentSelected!]!
    }
    
    let clientId = "a6d48d61-71a0-45eb-8957-f6d2e760f8f6"
    var stateCallbacks: [String: (String) -> Void] = [:]
    var msAccountVM: MicrosoftAccountVM? = nil
    
    init() {
        self.server = .init()
    }
}
