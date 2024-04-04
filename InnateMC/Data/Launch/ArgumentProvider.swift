import Foundation

public class ArgumentProvider {
    public var values: [String:String] = [:]
    
    public init() {
    }
    
    public func accept(_ str: [String]) -> [String] {
        var visited: [String] = []
        
        for component in str {
            if component[component.startIndex] != "$" {
                visited.append(component)
                continue
            }
            
            let variable = String(component.dropFirst(2).dropLast())
            
            if let value = values[variable] {
                visited.append(value)
            }
        }
        
        return visited
    }
    
    public func clientId(_ clientId: String) {
        self.values["clientId"] = clientId
    }
    
    public func xuid(_ xuid: String) {
        self.values["auth_xuid"] = xuid
    }
    
    public func username(_ username: String) {
        self.values["auth_player_name"] = username
    }
    
    public func version(_ version: String) {
        self.values["version_name"] = version
        self.values["version"] = version
    }
    
    public func gameDir(_ gameDir: URL) {
        self.values["game_directory"] = gameDir.path
    }
    
    public func assetsDir(_ assetsDir: URL) {
        self.values["assets_root"] = assetsDir.path
        self.values["game_assets"] = assetsDir.path
    }
    
    public func assetIndex(_ assetIndex: String) {
        self.values["assets_index_name"] = assetIndex
    }
    
    public func nativesDir(_ directory: String) {
        self.values["natives_directory"] = directory
    }
    
    public func uuid(_ uuid: UUID) {
        self.values["auth_uuid"] = uuid.uuidString
        self.values["uuid"] = uuid.uuidString
    }
    
    public func accessToken(_ accessToken: String) {
        self.values["auth_access_token"] = accessToken
        self.values["auth_session"] = accessToken
        self.values["accessToken"] = accessToken
    }
    
    public func userType(_ userType: String) {
        self.values["user_type"] = userType
    }
    
    public func versionType(_ versionType: String) {
        self.values["version_type"] = versionType
    }
    
    public func width(_ width: Int) {
        self.values["resolution_width"] = String(width)
    }
    
    public func height(_ height: Int) {
        self.values["resolution_height"] = String(height)
    }
}
