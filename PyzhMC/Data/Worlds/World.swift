import Foundation

public struct World: Hashable {
    let folder: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.folder)
    }
}

extension Array where Element == URL {
    func deserializeToWorlds() -> [World] {
        self.filter {
            $0.hasDirectoryPath
        }
        .compactMap {
            World(folder: $0.lastPathComponent)
        }
    }
}