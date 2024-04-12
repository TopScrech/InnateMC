import Foundation

extension Instance {
    func save() throws {
        try FileHandler.saveData(getPath().appendingPathComponent("Instance.plist"), serialize())
    }
    
    func serialize() throws -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        return try encoder.encode(self)
    }
    
    internal static func deserialize(_ data: Data, path: URL) throws -> Instance {
        let decoder = PropertyListDecoder()
        
        return try decoder.decode(Instance.self, from: data)
    }
    
    static func loadFromDirectory(_ url: URL) throws -> Instance {
        try deserialize(FileHandler.getData(url.appendingPathComponent("Instance.plist"))!, path: url)
    }
    
    static func loadInstances() throws -> [Instance] {
        var instances: [Instance] = []
        
        let directoryContents = try FileManager.default.contentsOfDirectory(
            at: FileHandler.instancesFolder,
            includingPropertiesForKeys: nil
        )
        
        for url in directoryContents {
            if !url.hasDirectoryPath {
                continue
            }
            
            if !url.lastPathComponent.hasSuffix(".pyzh") {
                continue
            }
            
            let instance: Instance
            
            do {
                instance = try Instance.loadFromDirectory(url)
            } catch {
                logger.error("Error loading instance at \(url.path)", error: error)
                
                ErrorTracker.instance.error(
                    error: error,
                    description: "Error loading instance at \(url.path)"
                )
                
                logger.notice("Disabling invalid instance at \(url.path)")
                try FileManager.default.moveItem(at: url, to: url.appendingPathExtension("_old"))
                
                continue
            }
            
            instances.append(instance)
            logger.info("Loaded instance \(instance.name)")
        }
        
        return instances
    }
    
    static func loadInstancesThrow() -> [Instance] {
        try! loadInstances()
    }
    
    func createAsNewInstance() throws {
        let instancePath = getPath()
        let fm = FileManager.default
        
        if fm.fileExists(atPath: instancePath.path) {
            logger.notice("Instance already exists at path, overwriting")
            try fm.removeItem(at: instancePath)
        }
        
        try fm.createDirectory(at: instancePath, withIntermediateDirectories: true)
        try FileHandler.saveData(instancePath.appendingPathComponent("Instance.plist"), serialize())
        
        logger.info("Successfully created new instance \(self.name)")
    }
    
    func delete() {
        do {
            try FileManager.default.removeItem(at: getPath())
            logger.info("Successfully deleted instance \(self.name)")
        } catch {
            logger.error("Error deleting instance \(name)", error: error)
            
            ErrorTracker.instance.error(
                error: error,
                description: "Error deleting instance \(name)"
            )
        }
    }
    
    func renameAsync(to newName: String) {
        let oldName = name
        
        DispatchQueue.global(qos: .userInteractive).async {
#warning("Handle the errors")
            let original = self.getPath()
            
            do {
                try FileManager.default.copyItem(at: original, to: Instance.getInstancePath(for: newName))
            } catch {
                logger.error("Error copying instance \(self.name) during rename", error: error)
                
                ErrorTracker.instance.error(
                    error: error,
                    description: "Error copying instance \(self.name) during rename"
                )
                
                return
            }
            
            DispatchQueue.main.async {
                self.name = newName
                
                DispatchQueue.global(qos: .userInteractive).async {
                    do {
                        try FileManager.default.removeItem(at: original)
                    } catch {
                        logger.error("Error deleting old instance \(self.name) during rename", error: error)
                        
                        ErrorTracker.instance.error(
                            error: error,
                            description: "Error deleting old instance \(self.name) during rename"
                        )
                    }
                }
                
                logger.info("Successfully renamed instance \(oldName) to \(newName)")
            }
        }
    }
}
