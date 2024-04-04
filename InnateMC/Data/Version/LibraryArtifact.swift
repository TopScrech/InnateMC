import Foundation

public struct LibraryArtifact: Codable, Equatable {
    public let path: String
    public let url: URL
    public let sha1: String?
    public let size: Int?
    
    public init(path: String, url: URL, sha1: String?, size: Int?) {
        self.path = path
        self.url = url
        self.sha1 = sha1
        self.size = size
    }
    
    private enum CodingKeys: String, CodingKey {
        case path,
             url,
             sha1,
             size
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decode(String.self, forKey: .path)
        sha1 = try container.decodeIfPresent(String.self, forKey: .sha1)
        size = try container.decodeIfPresent(Int.self, forKey: .size)
        
        if let urlString = try container.decodeIfPresent(String.self, forKey: .url),
           let url = URL(string: urlString) {
            self.url = url
        } else {
            throw DecodingError.dataCorruptedError(forKey: .url, in: container, debugDescription: "Invalid URL string")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        try container.encode(url.absoluteString, forKey: .url)
        try container.encodeIfPresent(sha1, forKey: .sha1)
        try container.encodeIfPresent(size, forKey: .size)
    }
    
    public func getAbsolutePath() -> URL {
        FileHandler.librariesFolder.appendingPathComponent(self.path, isDirectory: false)
    }
    
    public func asDownloadTask() -> DownloadTask {
        DownloadTask(sourceUrl: url, filePath: self.getAbsolutePath(), sha1: self.sha1) // TODO: fix sha1 checking for libraries
    }
}
