import Foundation

public struct PartialVersion: Codable, Hashable, Identifiable {
    public var id: Self { self }
    
    public var version: String
    public var type: String
    public var url: String
    public var time: String
    public var releaseTime: String
    public var sha1: String
    public var complianceLevel: Int
    
    enum CodingKeys: String, CodingKey {
        case version = "id",
             type,
             url,
             time,
             releaseTime,
             sha1,
             complianceLevel
    }
    
    public static func createBlank() -> PartialVersion {
        PartialVersion(id: "no", version: "no", type: "no", url: "no", time: "no", releaseTime: "no", sha1: "no", complianceLevel: 0)
    }
    
    public init(id: String, version: String, type: String, url: String, time: String, releaseTime: String, sha1: String, complianceLevel: Int) {
        self.version = version
        self.type = type
        self.url = url
        self.time = time
        self.releaseTime = releaseTime
        self.sha1 = sha1
        self.complianceLevel = complianceLevel
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        version = try container.decode(String.self, forKey: .version)
        type = try container.decode(String.self, forKey: .type)
        url = try container.decode(String.self, forKey: .url)
        time = try container.decode(String.self, forKey: .time)
        releaseTime = try container.decode(String.self, forKey: .releaseTime)
        sha1 = try container.decode(String.self, forKey: .sha1)
        complianceLevel = try container.decode(Int.self, forKey: .complianceLevel)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(type, forKey: .type)
        try container.encode(url, forKey: .url)
        try container.encode(time, forKey: .time)
        try container.encode(releaseTime, forKey: .releaseTime)
        try container.encode(sha1, forKey: .sha1)
        try container.encode(complianceLevel, forKey: .complianceLevel)
    }
}
