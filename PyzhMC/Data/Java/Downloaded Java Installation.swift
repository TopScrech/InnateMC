import Foundation

public class DownloadedJavaInstallation: Codable, Identifiable {
    public let version: String
    public let path: String
}

extension DownloadedJavaInstallation {
    public static let filePath = FileHandler.javaFolder.appendingPathComponent("Index.plist")
    public static let encoder = PropertyListEncoder()
    public static let decoder = PropertyListDecoder()
    
    public static func load() throws -> [DownloadedJavaInstallation] {
        let data = try FileHandler.getData(filePath)
        
        guard let data else {
            return []
        }
        
        do {
            let versions: [DownloadedJavaInstallation] = try decoder.decode([DownloadedJavaInstallation].self, from: data)
            logger.info("Loaded \(versions.count) downloaded java installations")
            
            return versions
        } catch {
            return []
        }
    }
}

extension Array where Element == DownloadedJavaInstallation {
    func save() throws {
        DownloadedJavaInstallation.encoder.outputFormat = .xml
        
        let data = try DownloadedJavaInstallation.encoder.encode(self)
        try FileHandler.saveData(DownloadedJavaInstallation.filePath, data)
    }
}
