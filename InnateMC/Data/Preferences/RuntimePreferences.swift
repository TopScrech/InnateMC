import Foundation

public class RuntimePreferences: Codable, ObservableObject {
    @Published public var defaultJava: SavedJavaInstallation = .systemDefault
    @Published public var minMemory = 1024
    @Published public var maxMemory = 1024
    @Published public var javaArgs = ""
    @Published public var valid = true
    
    public init() {
        
    }
    
    public init(_ prefs: RuntimePreferences) {
        self.defaultJava = prefs.defaultJava
        self.minMemory = prefs.minMemory
        self.maxMemory = prefs.maxMemory
        self.javaArgs = prefs.javaArgs
        self.valid = prefs.valid
    }
    
    public func invalidate() -> RuntimePreferences {
        self.valid = false
        
        return self
    }
    
    public static func invalid() -> RuntimePreferences {
        .init().invalidate()
    }
}
