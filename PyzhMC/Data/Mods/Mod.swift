import Foundation

public struct Mod: Identifiable, Hashable, Comparable {
    public var id: Mod { self }
    var enabled: Bool
    var path: URL
    var meta: Mod.Metadata
    
    public static func == (lhs: Mod, rhs: Mod) -> Bool {
        lhs.path == rhs.path && lhs.enabled == rhs.enabled
    }
    
    public static func < (lhs: Mod, rhs: Mod) -> Bool {
        lhs.path.lastPathComponent < rhs.path.lastPathComponent
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(enabled)
        hasher.combine(path)
        hasher.combine(meta.name)
    }
    
    struct Metadata {
        let name: String
        let description: String
    }
    
    public static func isValidMod(url: URL) -> Bool {
        switch url.pathExtension.lowercased() {
        case "bak", "jar", "zip", "litemod":
            true
            
        default:
            false
        }
    }
    
    public static func isEnabled(_ url: URL) -> Bool {
        url.pathExtension.lowercased() != "bak"
    }
    
    public static func from(url: URL) throws -> Mod {
        .init(
            enabled: isEnabled(url),
            path: url,
            meta: .init(
                name: "no u",
                description: "testing"
            )
        )
    }
}

extension Array where Element == URL {
    func deserializeToMods() -> [Mod] {
        self.filter(Mod.isValidMod).compactMap {
            try? Mod.from(url: $0)
        }
    }
}
