import Foundation

struct Version: Decodable, Equatable {
    let arguments: Arguments
    let assetIndex: PartialAssetIndex
    let assets: String
    let complianceLevel: Int
    let downloads: MainDownloads
    let id: String
    let libraries: [Library]
    let logging: LoggingConfig?
    let mainClass: String
    let minimumLauncherVersion: Int
    let releaseTime: String
    let time: String
    let type: String
    let inheritsFrom: String?
    
    var isInheritor: Bool {
        inheritsFrom != nil
    }
    
    init(arguments: Arguments, assetIndex: PartialAssetIndex, assets: String, complianceLevel: Int, downloads: MainDownloads, id: String, libraries: [Library], logging: LoggingConfig?, mainClass: String, minimumLauncherVersion: Int, releaseTime: String, time: String, type: String, inheritsFrom: String?) {
        self.arguments = arguments
        self.assetIndex = assetIndex
        self.assets = assets
        self.complianceLevel = complianceLevel
        self.downloads = downloads
        self.id = id
        self.libraries = libraries
        self.logging = logging
        self.mainClass = mainClass
        self.minimumLauncherVersion = minimumLauncherVersion
        self.releaseTime = releaseTime
        self.time = time
        self.type = type
        self.inheritsFrom = inheritsFrom
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var arguments = try container.decodeIfPresent(Arguments.self, forKey: .arguments)
        
        if arguments == nil {
            let mcArgs: String? = try container.decodeIfPresent(String.self, forKey: .minecraftArguments)
            
            if let mcArgs {
                arguments = .init(game: mcArgs.split(separator: " ").map { ArgumentElement.string(String($0)) }, jvm: [])
            }
        }
        
        self.arguments = arguments ?? Arguments.none
        assetIndex = try container.decodeIfPresent(PartialAssetIndex.self, forKey: .assetIndex) ?? PartialAssetIndex.none
        assets = try container.decodeIfPresent(String.self, forKey: .assets) ?? "3"
        complianceLevel = try container.decodeIfPresent(Int.self, forKey: .complianceLevel) ?? 3
        downloads = try container.decodeIfPresent(MainDownloads.self, forKey: .downloads) ?? MainDownloads.none
        id = try container.decode(String.self, forKey: .id)
        libraries = try container.decodeIfPresent([Library].self, forKey: .libraries) ?? []
        logging = try container.decodeIfPresent(LoggingConfig.self, forKey: .logging)
        mainClass = try container.decodeIfPresent(String.self, forKey: .mainClass) ?? "none"
        minimumLauncherVersion = try container.decodeIfPresent(Int.self, forKey: .minimumLauncherVersion) ?? 0
        releaseTime = try container.decode(String.self, forKey: .releaseTime)
        time = try container.decode(String.self, forKey: .time)
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        inheritsFrom = try container.decodeIfPresent(String.self, forKey: .inheritsFrom)
    }
    
    enum CodingKeys: String, CodingKey {
        case arguments,
             assetIndex,
             assets,
             complianceLevel,
             downloads,
             id,
             libraries,
             logging,
             mainClass,
             minimumLauncherVersion,
             releaseTime,
             time,
             type,
             inheritsFrom,
             minecraftArguments
    }
    
    func validate() -> Bool {
        if self.isInheritor {
            print("1")
            return false
        }
        guard self.arguments != Arguments.none else {
            print("2")
            return false
        }
        guard self.assetIndex != PartialAssetIndex.none else {
            print("3")
            return false
        }
        guard self.downloads != MainDownloads.none else {
            print("4")
            return false
        }
        if self.type.isEmpty {
            print("5")
            return false
        }
        if self.mainClass == "none" {
            print("6")
            return false
        }
        return true
    }
    
    func flatten(provider: @escaping ((String) throws -> Version)) throws -> Version {
        guard let parentId = self.inheritsFrom else {
            if !self.validate() {
                throw VersionError.invalidVersionData
            }
            
            return self
        }
        
        let unflattened = try provider(parentId)
        let parent = try unflattened.flatten(provider: provider)
        let newArguments = parent.arguments + self.arguments
        let newAssetIndex = self.assetIndex.default(fallback: parent.assetIndex)
        let newAssets = parent.assets
        let newDownloads = self.downloads | parent.downloads
        let newLibraries = parent.libraries + self.libraries
        let newLogging = self.logging == nil ? parent.logging : self.logging
        let newMainClass = self.mainClass == "none" ? parent.mainClass : self.mainClass
        let newNewMinLauncherVersion = self.minimumLauncherVersion
        let newType = self.type.isEmpty ? parent.type : self.type
        
        return .init(
            arguments: newArguments,
            assetIndex: newAssetIndex,
            assets: newAssets,
            complianceLevel: self.complianceLevel,
            downloads: newDownloads,
            id: self.id,
            libraries: newLibraries,
            logging: newLogging,
            mainClass: newMainClass,
            minimumLauncherVersion: newNewMinLauncherVersion,
            releaseTime: self.releaseTime,
            time: self.time,
            type: newType,
            inheritsFrom: nil
        )
    }
    
    func flatten() throws -> Version {
        try self.flatten { versionId in
            let parentPartial = LauncherData.instance.versionManifest
                .filter {
                    $0.version == versionId
                }
                .first
            
            guard let parentPartial = parentPartial else {
                throw VersionError.invalidParent
            }
            
            return try Version.downloadRaw(URL(string: parentPartial.url)!, sha1: parentPartial.sha1)
        }
    }
    
    enum VersionError: Error {
        case invalidVersionData,
             invalidParent
        
        var localizedDescription: String {
            switch(self) {
            case .invalidVersionData:
                "Invalid version data"
                
            case .invalidParent:
                "Invalid parent"
            }
        }
    }
    
    private static let jsonDecoder = JSONDecoder()
    
    static func download(_ url: URL, sha1: String?) throws -> Version {
        let rawVersion = try downloadRaw(url, sha1: sha1)
        
        let version = try rawVersion.flatten { versionId in
            let parentPartial = LauncherData.instance.versionManifest
                .filter {
                    $0.version == versionId
                }
                .first
            
            guard let parentPartial = parentPartial else {
                throw VersionError.invalidParent
            }
            
            return try downloadRaw(URL(string: parentPartial.url)!, sha1: parentPartial.sha1)
        }
        
        return version
    }
    
    private static func downloadRaw(_ url: URL, sha1: String?) throws -> Version {
        let data = try Data(contentsOf: url)
        
        print(String(data: data, encoding: .utf8)!)
        
        let rawVersion = try jsonDecoder.decode(Version.self, from: data)
        
        return rawVersion
    }
}
