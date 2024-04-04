import Foundation

public struct MinecraftJar: Codable {
    public var type: FileType
    public var url: URL?
    public var sha1: String?
    
    private enum CodingKeys: String, CodingKey {
        case type,
             url,
             sha1
    }
    
    public init(type: FileType, url: URL?, sha1: String?) {
        self.type = type
        self.url = url
        self.sha1 = sha1
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        type = try container.decode(FileType.self, forKey: .type)
        sha1 = try container.decodeIfPresent(String.self, forKey: .sha1)
        
        if let urlString = try container.decodeIfPresent(String.self, forKey: .url) {
            url = URL(string: urlString)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        try container.encode(sha1, forKey: .sha1)
        
        if let url {
            try container.encode(url.absoluteString, forKey: .url)
        }
    }
}
