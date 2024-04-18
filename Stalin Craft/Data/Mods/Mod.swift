import Foundation

func findFilePath(_ fileName: String, in directoryPath: String) -> String? {
    let fileManager = FileManager.default
    
    do {
        let items = try fileManager.contentsOfDirectory(atPath: directoryPath)
        
        if let foundFileName = items.first(where: { $0 == fileName }) {
            let filePath = (directoryPath as NSString).appendingPathComponent(foundFileName)
            
            return filePath
        } else {
            logger.error("File not found")
        }
        
    } catch {
        logger.error("Error reading contents of directory", error: error)
    }
    
    return nil
}

struct Mod: Identifiable, Hashable {
    var id: Mod { self }
    var enabled: Bool
    var path: URL
    var meta: FabricMod?
    
    static func == (lhs: Mod, rhs: Mod) -> Bool {
        lhs.path == rhs.path && lhs.enabled == rhs.enabled
    }
    
    static func < (lhs: Mod, rhs: Mod) -> Bool {
        lhs.path.lastPathComponent < rhs.path.lastPathComponent
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(enabled)
        hasher.combine(path)
        hasher.combine(meta?.name)
    }
    
    static func isValidMod(url: URL) -> Bool {
        switch url.pathExtension.lowercased() {
        case "jar", "zip", "litemod", "disabled":
            true
            
        default:
            false
        }
    }
    
    static func isEnabled(_ url: URL) -> Bool {
        !url.path.contains(".disabled")
    }
    
    static func from(url: URL) throws -> Mod {
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
                    logger.error("Failed to remove temporary directory", error: error)
                }
            }
            
            if let fabric = unzipModJar(
                jarFilePath: jarFilePath,
                destinationPath: tempDirURL.path
            ) {
                return .init(
                    enabled: isEnabled(url),
                    path: url,
                    meta: fabric
                )
            }
        } else {
            logger.error("Invalid file URL")
        }
        
        return .init(
            enabled: isEnabled(url),
            path: url,
            meta: nil
        )
    }
}
