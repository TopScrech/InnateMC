import Foundation

public struct Library: Codable, Equatable {
    public let downloads: LibraryDownloads
    public let name: String
    public let rules: [Rule]?
    
    public init(downloads: LibraryDownloads, name: String, rules: [Rule]?) {
        self.downloads = downloads
        self.name = name
        self.rules = rules
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let artifact = try? container.decode(ConcLibrary.self) {
            self.downloads = LibraryDownloads(artifact: LibraryArtifact(path: artifact.mavenStringToPath(), url: URL(string: artifact.mavenUrl())!, sha1: nil, size: nil))
            self.name = artifact.name
            self.rules = nil
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.downloads = try container.decode(LibraryDownloads.self, forKey: .downloads)
            self.rules = try container.decodeIfPresent([Rule].self, forKey: .rules)
        }
    }
    
    public struct ConcLibrary: Codable {
        public let name: String
        public let url: String
        
        func mavenStringToPath() -> String {
            let components = self.name.components(separatedBy: ":")
            let group = components[0].replacingOccurrences(of: ".", with: "/")
            let artifact = components[1].replacingOccurrences(of: ".", with: "/")
            let version = components[2]
            let path = "\(group)/\(artifact)/\(version)"
            
            return path
        }
        
        func mavenUrl() -> String {
            "\(url)\(mavenStringToPath())"
        }
    }
}

public struct LibraryDownloads: Codable, Equatable {
    public var artifact: LibraryArtifact?
    public var classifiers: LibraryClassifiers? = nil
    
    public struct LibraryClassifiers: Codable, Equatable {
        var nativesOsx: LibraryArtifact?
        
        public enum CodingKeys: String, CodingKey {
            case nativesOsx = "natives-osx"
        }
    }
    
    public var artifacts: [LibraryArtifact] {
        var arr: [LibraryArtifact] = []
        if let classifiers, let natives = classifiers.nativesOsx {
            arr.append(natives)
        }
        
        if let artifact {
            arr.append(artifact)
        }
        
        return arr
    }
}
