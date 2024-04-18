import ScrechKit
import Zip

func unzipModJar(jarFilePath: String, destinationPath: String) -> FabricMod? {
    guard let url = URL(string: jarFilePath) else {
        return nil
    }
    
    let fabricMod = "fabric.mod.json"
    
    do {
        let unzip = try Zip.quickUnzipFile(url).path
        
        if let path = findFilePath(fabricMod, in: unzip) {
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
