import ScrechKit

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

//struct FabricMod: Decodable {
//    let schemaVersion: Int
//    let id: String
//    let version: String
//    let name: String
//    let description: String
//    let authors: [String]
//    let contact: Contact
//    let license: String
//    let icon: String
//    let environment: String
//    let entrypoints: Entrypoints
//    let mixins: [String]
//    let accessWidener: String
//    let depends: Dependencies
//    
//    struct Contact: Decodable {
//        let homepage: String
//        let sources: String
//    }
//    
//    struct Entrypoints: Decodable {
//        let main: [String]
//        let client: [String]
//        let jeiModPlugin: [String]
//        
//        enum CodingKeys: String, CodingKey {
//            case main, client
//            case jeiModPlugin = "jei_mod_plugin"
//        }
//    }
//    
//    struct Dependencies: Decodable {
//        let fabricloader: String
//        let fabricApi: String
//        let minecraft: String
//        let java: String
//        
//        enum CodingKeys: String, CodingKey {
//            case fabricloader
//            case fabricApi = "fabric-api"
//            case minecraft, java
//        }
//    }
//}
//
//// Example usage:
//func decodeFabricModJson(from filePath: String) {
//    guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
//        print("Failed to read file")
//        return
//    }
//    
//    let decoder = JSONDecoder()
//    do {
//        let fabricMod = try decoder.decode(FabricMod.self, from: data)
//        print("Decoded fabric.mod.json: \(fabricMod)")
//        // Now `fabricMod` contains all the data from the JSON, and you can use it as needed.
//    } catch {
//        print("Failed to decode JSON: \(error)")
//    }
//}
