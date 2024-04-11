import Foundation

func findFilePath(in directoryPath: String, fileName: String) -> String? {
    let fileManager = FileManager.default
    
    do {
        let items = try fileManager.contentsOfDirectory(atPath: directoryPath)
        
        if let foundFileName = items.first(where: { $0 == fileName }) {
            let filePath = (directoryPath as NSString).appendingPathComponent(foundFileName)
            
            return filePath
        } else {
            print("File not found")
        }
    } catch {
        print("Error reading contents of directory: \(error)")
    }
    
    return nil
}

public struct Mod: Identifiable, Hashable {
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
        let fileManager = FileManager.default
        
        func pathFromFileURLString(_ fileURLString: String) -> String? {
            guard let url = URL(string: fileURLString),
                  url.scheme == "file" else {
                return nil
            }
            
            return url.path
        }
        
        if let jarFilePath = pathFromFileURLString(url.absoluteString) {
            let tempDirURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            
            try? fileManager.createDirectory(
                at: tempDirURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            defer {
                do {
                    try fileManager.removeItem(at: tempDirURL)
                } catch {
                    print("Failed to remove temporary directory: \(error)")
                }
            }
            
            if let fabric = unzipModJar(
                jarFilePath: jarFilePath,
                destinationPath: tempDirURL.path
            ) {
                return .init(
                    enabled: isEnabled(url),
                    path: url,
                    meta: .init(
                        name: fabric.name,
                        description: fabric.description
                    )
                )
            }
        } else {
            print("Invalid file URL")
        }
        
        return .init(
            enabled: isEnabled(url),
            path: url,
            meta: .init(
                name: url.lastPathComponent,
                description: "Error"
            )
        )
    }
}

extension Array where Element == URL {
    func deserializeToMods() -> [Mod] {
        return self.filter(Mod.isValidMod).compactMap {
            try? Mod.from(url: $0)
        }
    }
}
