import Foundation

struct MicrosoftAccount: MinecraftAccount {
    private static let decoder = JSONDecoder()
    
    var type: MinecraftAccountType = .microsoft
    var profile: MinecraftProfile
    var token: MicrosoftAccessToken
    
    var username: String {
        profile.name
    }
    
    var id: UUID {
        UUID(uuidString: hyphenateUuid(profile.id))!
    }
    var xuid: String {
        username // TODO: decode JWT?
    }
    
    public init(profile: MinecraftProfile, token: MicrosoftAccessToken) {
        self.profile = profile
        self.token = token
    }
    
    func createAccessToken() async throws -> String {
        logger.debug("Fetching access token for \(profile.name):\(profile.id)")
        let manager = LauncherData.instance.accountManager
        
        if token.hasExpired() {
            let newAccount: MicrosoftAccount
            
            do {
                let newToken = try await manager.refreshMicrosoftToken(self.token)
                newAccount = MicrosoftAccount(profile: self.profile, token: newToken)
                manager.accounts[self.id] = newAccount
                
                DispatchQueue.global(qos: .utility).async {
                    manager.saveThrow()
                }
            } catch let err as MicrosoftAuthError {
                logger.error("Could not refresh token", error: err)
                ErrorTracker.instance.error(error: err, description: NSLocalizedString("error_refreshing_token", comment: "Could not refresh microsoft account token"))
                
                return "nou"
            }
            
            return try await newAccount.createAccessToken()
        }
        
        let xblResponse = try await manager.authenticateWithXBL(msAccessToken: self.token.token)
        logger.debug("Authenticated with xbox live")
        
        let xstsResponse: XboxAuthResponse = try await manager.authenticateWithXSTS(xblToken: xblResponse.token)
        logger.debug("Authenticated with xbox xsts")
        
        let mcResponse: MinecraftAuthResponse = try await manager.authenticateWithMinecraft(using: .init(xsts: xstsResponse))
        logger.debug("Authenticated with minecraft")
        
        return mcResponse.accessToken
    }
}

private func hyphenateUuid(_ thing: String) -> String {
    var uuid = thing
    uuid.insert("-", at: uuid.index(uuid.startIndex, offsetBy: 8))
    uuid.insert("-", at: uuid.index(uuid.startIndex, offsetBy: 13))
    uuid.insert("-", at: uuid.index(uuid.startIndex, offsetBy: 18))
    uuid.insert("-", at: uuid.index(uuid.startIndex, offsetBy: 23))
    
    return uuid
}
