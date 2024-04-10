import Foundation
import Swifter

class AccountManager: ObservableObject {
    public static let accountsPath = try! FileHandler.getOrCreateFolder().appendingPathComponent("Accounts.plist")
    public static let plistEncoder = PropertyListEncoder()
    public let server: HttpServer
    public var serverThread: DispatchQueue?
    
    @Published public var currentSelected: UUID? = nil
    @Published public var accounts: [UUID:any MinecraftAccount] = [:]
    
    public var selectedAccount: any MinecraftAccount {
        return accounts[currentSelected!]!
    }
    
    public let clientId = "a6d48d61-71a0-45eb-8957-f6d2e760f8f6"
    public var stateCallbacks: [String: (String) -> Void] = [:]
    public var msAccountVM: MicrosoftAccountVM? = nil
    
    public init() {
        self.server = .init()
    }
}
