import SwiftUI
import FileWatcher

public class Instance: Identifiable, Hashable, InstanceData, ObservableObject {
    @Published public var name: String
    
    public var assetIndex: PartialAssetIndex
    public var libraries: [LibraryArtifact]
    public var mainClass: String
    public var minecraftJar: MinecraftJar
    
    @Published public var isStarred: Bool
    @Published public var logo: InstanceLogo
    @Published public var notes: String?
    @Published public var synopsis: String?
    
    public var debugString: String
    
    public var synopsisOrVersion: String {
        get {
            synopsis ?? debugString
        }
        
        set(newValue) {
            synopsis = newValue
        }
    }
    
    public var lastPlayed: Date?
    public var preferences = InstancePreferences()
    public var arguments: Arguments
    
    @Published public var mods: [Mod] = []
    @Published public var screenshots: [Screenshot] = []
    @Published public var worlds: [World] = []
    
    public var screenshotsWatcher: FileWatcher? = nil
    public var modsWatcher:        FileWatcher? = nil
    public var worldsWatcher:      FileWatcher? = nil
    
    public init(
        name: String,
        assetIndex: PartialAssetIndex,
        libraries: [LibraryArtifact],
        mainClass: String,
        minecraftJar: MinecraftJar,
        isStarred: Bool,
        logo: InstanceLogo,
        description: String?,
        debugString: String,
        arguments: Arguments
    ) {
        self.name = name
        self.assetIndex = assetIndex
        self.libraries = libraries
        self.mainClass = mainClass
        self.minecraftJar = minecraftJar
        self.isStarred = isStarred
        self.logo = logo
        self.notes = description
        self.debugString = debugString
        self.arguments = arguments
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name,         forKey: .name)
        try container.encode(assetIndex,   forKey: .assetIndex)
        try container.encode(libraries,    forKey: .libraries)
        try container.encode(mainClass,    forKey: .mainClass)
        try container.encode(minecraftJar, forKey: .minecraftJar)
        try container.encode(isStarred,    forKey: .isStarred)
        try container.encode(logo,         forKey: .logo)
        try container.encode(notes,        forKey: .notes)
        try container.encode(synopsis,     forKey: .synopsis)
        try container.encode(debugString,  forKey: .debugString)
        try container.encode(lastPlayed,   forKey: .lastPlayed)
        try container.encode(preferences,  forKey: .preferences)
        try container.encode(arguments,    forKey: .arguments)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name =          try container.decode(String.self, forKey: .name)
        assetIndex =    try container.decode(PartialAssetIndex.self, forKey: .assetIndex)
        libraries =     try container.decode([LibraryArtifact].self, forKey: .libraries)
        mainClass =     try container.decode(String.self, forKey: .mainClass)
        minecraftJar =  try container.decode(MinecraftJar.self, forKey: .minecraftJar)
        isStarred =     try container.decode(Bool.self, forKey: .isStarred)
        logo =          try container.decode(InstanceLogo.self, forKey: .logo)
        notes =         try container.decode(String?.self, forKey: .notes)
        synopsis =      try container.decode(String?.self, forKey: .synopsis)
        debugString =   try container.decode(String.self, forKey: .debugString)
        lastPlayed =    try container.decodeIfPresent(Date.self, forKey: .lastPlayed)
        preferences =   try container.decode(InstancePreferences.self, forKey: .preferences)
        arguments =     try container.decode(Arguments.self, forKey: .arguments)
    }
    
    private enum CodingKeys: String, CodingKey {
        case name,
             assetIndex,
             libraries,
             mainClass,
             minecraftJar,
             isStarred,
             logo,
             notes,
             synopsis,
             debugString,
             synopsisOrVersion,
             lastPlayed,
             preferences,
             arguments,
             
             // Legacy
             startOnFirstThread,
             gameArguments
    }
    
    public static func getInstancePath(for name: String) -> URL {
        FileHandler.instancesFolder.appendingPathComponent(name + ".pyzh", isDirectory: true)
    }
    
    public func setPreferences(_ prefs: InstancePreferences) {
        preferences = prefs
    }
    
    public func getPath() -> URL {
        Instance.getInstancePath(for: name)
    }
    
    public func getGamePath() -> URL {
        getPath().appendingPathComponent("minecraft", isDirectory: true)
    }
    
    public func getNativesFolder() -> URL {
        getPath().appendingPathComponent("natives", isDirectory: true)
    }
    
    public func getMcJarPath() -> URL {
        getPath().appendingPathComponent("minecraft.jar")
    }
    
    public func getLogoPath() -> URL {
        getPath().appendingPathComponent("logo.png")
    }
    
    public func getModsFolder() -> URL {
        getGamePath().appendingPathComponent("mods")
    }
    
    public func getScreenshotsFolder() -> URL {
        getGamePath().appendingPathComponent("screenshots")
    }
    
    public func getLogsFolder() -> URL {
        getGamePath().appendingPathComponent("logs")
    }
    
    public func getSavesFolder() -> URL {
        getGamePath().appendingPathComponent("saves")
    }
    
    public func matchesSearchTerm(_ term: String) -> Bool {
        if term.isEmpty {
            return true
        }
        
        return name.localizedCaseInsensitiveContains(term) || synopsisOrVersion.localizedCaseInsensitiveContains(term)
    }
    
    public func processArgsByRules(_ thing: KeyPath<Arguments, [ArgumentElement]>, features: [String:Bool]) -> [String] {
        arguments[keyPath: thing].filter { element in
            switch(element) {
            case .string:
                true
                
            case .object(let obj):
                obj.rules.allMatchRules(givenFeatures: features)
            }
        }
        .flatMap {
            $0.actualValue
        }
    }
    
    public static func == (lhs: Instance, rhs: Instance) -> Bool {
        lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(notes)
        hasher.combine(synopsisOrVersion)
    }
    
    public func loadScreenshotsAsync() {
        let folder = getScreenshotsFolder()
        
        if screenshotsWatcher == nil {
            let watcher = FileWatcher([folder.path])
            watcher.queue = DispatchQueue.global(qos: .background)
            
            watcher.callback = { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.loadScreenshotsAsync()
                }
            }
            
            screenshotsWatcher = watcher
            watcher.start()
        }
        
        Task {
            let fm = FileManager.default
            var isDirectory: ObjCBool = true
            
            if fm.fileExists(atPath: folder.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                let urls: [URL]
                
                do {
                    urls = try fm.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
                } catch {
                    ErrorTracker.instance.error(error: error, description: "Error reading screenshots folder for instance \(name)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.screenshots = urls.deserializeToScreenshots().sorted()
                }
            }
        }
    }
    
    public func loadModsAsync() {
        let modsFolder = getModsFolder()
        
        if modsWatcher == nil {
            let watcher = FileWatcher([modsFolder.path])
            watcher.queue = DispatchQueue.global(qos: .background)
            
            watcher.callback = { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.loadModsAsync()
                }
            }
            
            modsWatcher = watcher
            watcher.start()
        }
        
        Task {
            let fm = FileManager.default
            var isDirectory: ObjCBool = true
            
            if fm.fileExists(atPath: modsFolder.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                let urls: [URL]
                
                do {
                    urls = try fm.contentsOfDirectory(at: modsFolder, includingPropertiesForKeys: nil)
                } catch {
                    logger.error("Error reading mods folder for instance \(name)", error: error)
                    
                    ErrorTracker.instance.error(
                        error: error,
                        description: "Error reading mods folder for instance \(name)"
                    )
                    
                    return
                }
                
                DispatchQueue.main.async {
                    self.mods = urls.deserializeToMods()
                }
            }
        }
    }
    
    public func loadWorldsAsync() {
        let worldsFolder = getSavesFolder()
        
        if worldsWatcher == nil {
            let watcher = FileWatcher([worldsFolder.path])
            watcher.queue = DispatchQueue.global(qos: .background)
            
            watcher.callback = { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.loadWorldsAsync()
                }
            }
            
            worldsWatcher = watcher
            watcher.start()
        }
        
        Task {
            let fm = FileManager.default
            var isDirectory: ObjCBool = true
            
            if fm.fileExists(atPath: worldsFolder.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                let urls: [URL]
                
                do {
                    urls = try fm.contentsOfDirectory(at: worldsFolder, includingPropertiesForKeys: nil)
                    print(urls)
                } catch {
                    logger.error("Error reading mods folder for instance \(name)", error: error)
                    
                    ErrorTracker.instance.error(
                        error: error,
                        description: "Error reading mods folder for instance \(name)"
                    )
                    
                    return
                }
                
                DispatchQueue.main.async {
                    self.worlds = urls.deserializeToWorlds()
                }
            }
        }
    }
}
