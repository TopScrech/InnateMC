import ScrechKit

func unzipModJar(jarFilePath: String, destinationDirectoryPath: String) -> FabricMod? {
    let process = Process()
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["unzip", jarFilePath, "-d", destinationDirectoryPath]
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    
    outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
        let data = fileHandle.availableData
        
//        if let output = String(data: data, encoding: .utf8) {
//            print(output)
//        }
    }
    
    errorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
        let data = fileHandle.availableData
        
//        if let output = String(data: data, encoding: .utf8) {
//            print(output)
//        }
    }
    
    do {
        try process.run()
        process.waitUntilExit()
        
        // Clean up
        outputPipe.fileHandleForReading.readabilityHandler = nil
        errorPipe.fileHandleForReading.readabilityHandler = nil
        
        let fileName = "fabric.mod.json"
        
        if let path = findFilePath(in: destinationDirectoryPath, fileName: fileName) {
            return decodeFabricModJson(path)
        }
    } catch {
        print("Failed to start the unzip process: \(error)")
    }
    
    return nil
}

func decodeFabricModJson(_ filePath: String) -> FabricMod? {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
        print("Failed to read file")
        return nil
    }
    
    let decoder = JSONDecoder()
    
    do {
        let fabricMod = try decoder.decode(FabricMod.self, from: data)
        print("Decoded fabric.mod.json: \(fabricMod)")
        
        return fabricMod
    } catch {
        print("Failed to decode JSON: \(error)")
        return nil
    }
}
