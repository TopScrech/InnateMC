import ScrechKit

func unzipModJar(jarFilePath: String, destinationPath: String) -> FabricMod? {
    let process = Process()
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["unzip", jarFilePath, "-d", destinationPath]
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    
    outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
        let data = fileHandle.availableData
        
        if let output = String(data: data, encoding: .utf8) {
            logger.debug("Output pipe: \(output)")
        }
    }
    
    errorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
        let data = fileHandle.availableData
        
        if let output = String(data: data, encoding: .utf8) {
            logger.debug("Error pipe: \(output)")
        }
    }
    
    do {
        try process.run()
        process.waitUntilExit()
        
        // Clean up
        outputPipe.fileHandleForReading.readabilityHandler = nil
        errorPipe.fileHandleForReading.readabilityHandler = nil
        
        let fileName = "fabric.mod.json"
        
        if let path = findFilePath(in: destinationPath, fileName: fileName) {
            return decodeFabricModJson(path)
        }
    } catch {
        logger.error("Failed to start the unzip process", error: error)
    }
    
    return nil
}

func decodeFabricModJson(_ filePath: String) -> FabricMod? {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
        logger.error("Failed to read file")
        
        return nil
    }
    
    let decoder = JSONDecoder()
    
    do {
        let mod = try decoder.decode(FabricMod.self, from: data)
        
        return mod
        
    } catch {
        logger.error("Failed to decode JSON", error: error)
        
        return nil
    }
}
