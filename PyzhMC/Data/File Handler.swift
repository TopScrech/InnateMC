import Foundation

public class FileHandler {
    public static let instancesFolder = try! getOrCreateFolder("Instances")
    public static let assetsFolder = try! getOrCreateFolder("Assets")
    public static let librariesFolder = try! getOrCreateFolder("Libraries")
    public static let javaFolder: URL = try! getOrCreateFolder("Java")
    
    public static func getOrCreateFolder() throws -> URL {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folderUrl = appSupport.appendingPathComponent("PyzhMC")
        
        if !fileManager.fileExists(atPath: folderUrl.path) {
            logger.info("Creating directory in user's application support folder")
            try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        return folderUrl
    }
    
    public static func getOrCreateFolder(_ name: String) throws -> URL {
        let fileManager = FileManager.default
        let folderUrl = try getOrCreateFolder().appendingPathComponent(name)
        
        if !fileManager.fileExists(atPath: folderUrl.path) {
            logger.info("Creating subdirectory \(name) in PyzhMC")
            try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
        }
        
        return folderUrl
    }
    
    public static func getData(_ url: URL) throws -> Data? {
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        
        return try Data(contentsOf: url)
    }
    
    public static func saveData(_ url: URL, _ data: Data) throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: data)
        } else {
            try data.write(to: url)
        }
    }
}
