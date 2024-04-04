import Foundation

public class GlobalPreferences: Codable, ObservableObject {
    @Published public var runtime = RuntimePreferences()
    @Published public var ui = UiPreferences()
}

extension GlobalPreferences {
    public static let filePath = try! FileHandler.getOrCreateFolder().appendingPathComponent("Preferences.plist")
    
    public static func load() throws -> GlobalPreferences {
        if let data = try FileHandler.getData(filePath) {
            return try PropertyListDecoder().decode(GlobalPreferences.self, from: data)
        } else {
            let prefs = GlobalPreferences()
            prefs.save()
            
            return prefs
        }
    }
    
    public func save() {
        let encoder: PropertyListEncoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        do {
            let data = try encoder.encode(self)
            try FileHandler.saveData(GlobalPreferences.filePath, data)
        } catch {
            logger.error("Could not serialize preferences")
            ErrorTracker.instance.error(error: error, description: "Could not serialize preferences")
        }
    }
}
