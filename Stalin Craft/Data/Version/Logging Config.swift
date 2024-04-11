import Foundation

public struct LoggingConfig: Codable, Equatable {
    public static let none = LoggingConfig(client: .none)
    
    public let client: ClientLoggingConfig
}

public struct ClientLoggingConfig: Codable, Equatable {
    public static let none = ClientLoggingConfig(
        argument: "", 
        file: .none,
        type: ""
    )
    
    public let argument: String
    public let file: LoggingArtifact
    public let type: String
}

public struct LoggingArtifact: Codable, Equatable {
    public static let none = LoggingArtifact(
        id: "", 
        sha1: "",
        size: 0,
        url: URL(string: "/")!
    )
    
    public let id: String
    public let sha1: String
    public let size: Int
    public let url: URL
}
