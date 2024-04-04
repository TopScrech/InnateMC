import Foundation

public struct InstanceLogo: Codable {
    public var logoType: LogoType
    public var string: String
    
    public enum LogoType: String, Codable {
        case symbol,
             file,
             builtin
    }
}
