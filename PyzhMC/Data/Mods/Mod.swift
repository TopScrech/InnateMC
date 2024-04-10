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
        func pathFromFileURLString(_ fileURLString: String) -> String? {
            guard let url = URL(string: fileURLString),
                  url.scheme == "file" else { return nil }
            return url.path
        }

        // Adjusted function call
        if let jarFilePath = pathFromFileURLString("file:///Users/topscrech/Library/Application%20Support/PyzhMC/Instances/New%20Instance.pyzh/minecraft/mods/jei-1.19.2-fabric-11.6.0.1019.jar"),
           let destinationDirectoryPath = pathFromFileURLString("file:///Users/topscrech/Library/Application%20Support/PyzhMC/Instances/New%20Instance.pyzh/minecraft/mods") {
            unzipModJar(jarFilePath: jarFilePath, destinationDirectoryPath: destinationDirectoryPath)
        } else {
            print("Invalid file URL")
        }

        return .init(
            enabled: isEnabled(url),
            path: url,
            meta: .init(
                name: "Example Mod Name",
                description: "Description of the mod."
            )
        )
    }
}

func unzipModJar(jarFilePath: String, destinationDirectoryPath: String) {
    let process = Process()
    let pipe = Pipe()
    
    // Using `/usr/bin/env unzip` to ensure the environment's `unzip` is used.
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["unzip", jarFilePath, "-d", destinationDirectoryPath]
    process.standardOutput = pipe
    process.standardError = pipe
    
    do {
        try process.run()
        process.waitUntilExit()
        
        // Optionally, read and print the output from the unzip command
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        if let output = String(data: data, encoding: .utf8) {
            print(output)
        }
        
        if process.terminationStatus == 0 {
            print("Unzip successful")
        } else {
            print("Unzip failed")
        }
    } catch {
        print("Failed to start the unzip process: \(error)")
    }
}

extension Array where Element == URL {
    func deserializeToMods() -> [Mod] {
        return self.filter(Mod.isValidMod).compactMap {
            try? Mod.from(url: $0)
        }
    }
}
