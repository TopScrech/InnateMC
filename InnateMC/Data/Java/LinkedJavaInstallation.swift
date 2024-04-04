import Foundation

public class LinkedJavaInstallation: Codable {
    public let JVMArch:            String
    public let JVMBundleID:        String
    public let JVMEnabled:         Bool
    public let JVMHomePath:        String
    public let JVMName:            String
    public let JVMPlatformVersion: String
    public let JVMVendor:          String
    public let JVMVersion:         String
}

extension LinkedJavaInstallation {
    private static let decoder: PropertyListDecoder = PropertyListDecoder()
    
    public static func getAll() throws -> [LinkedJavaInstallation] {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/libexec/java_home")
        p.arguments = ["-X"]
        
        let pipe = Pipe()
        p.standardOutput = pipe
        p.launch()
        
        let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
        let installations = try decoder.decode([LinkedJavaInstallation].self, from: data)
        
        return installations
    }
}
