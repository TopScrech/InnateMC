import CoreFoundation
import Foundation

public struct MicrosoftAccessToken: Codable {
    public var token: String
    public var expiry: Int
    public var refreshToken: String
    
    public init(token: String, expiry: Int, refreshToken: String) {
        self.token = token
        self.expiry = expiry
        self.refreshToken = refreshToken
    }
    
    public init(token: String, expiresIn: Int, refreshToken: String) {
        self.token = token
        self.expiry = Int(CFAbsoluteTimeGetCurrent()) + expiresIn
        self.refreshToken = refreshToken
    }
    
    public static func fromJson(json data: Data) throws -> MicrosoftAccessToken {
        do {
            return try JSONDecoder().decode(RawMicrosoftAccessToken.self, from: data).convert()
        } catch {
            throw MicrosoftAuthError.microsoftInvalidResponse
        }
    }
    
    public func hasExpired() -> Bool {
        Int(CFAbsoluteTimeGetCurrent()) > expiry - 5
    }
}

struct RawMicrosoftAccessToken: Codable {
    public var access_token: String
    public var refresh_token: String
    public var expires_in: Int
    
    public func convert() -> MicrosoftAccessToken {
        MicrosoftAccessToken(token: access_token, expiresIn: expires_in, refreshToken: refresh_token)
    }
}
