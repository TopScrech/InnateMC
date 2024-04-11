import Foundation

class RuntimePreferences: Codable, ObservableObject {
    @Published var defaultJava: SavedJavaInstallation = .systemDefault
    @Published var minMemory = 1024
    @Published var maxMemory = 1024
    @Published var javaArgs = ""
    @Published var valid = true
    
    init() {
        
    }
    
    init(_ prefs: RuntimePreferences) {
        self.defaultJava = prefs.defaultJava
        self.minMemory = prefs.minMemory
        self.maxMemory = prefs.maxMemory
        self.javaArgs = prefs.javaArgs
        self.valid = prefs.valid
    }
    
    func invalidate() -> RuntimePreferences {
        self.valid = false
        
        return self
    }
    
    static func invalid() -> RuntimePreferences {
        .init().invalidate()
    }
}
