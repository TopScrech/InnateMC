import Foundation

struct World: Hashable {
    let folder: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(folder)
    }
}

extension Array where Element == URL {
    func deserializeToWorlds() -> [World] {
        self.filter {
            $0.hasDirectoryPath
        }
        .compactMap {
            .init(folder: $0.lastPathComponent)
        }
    }
}
