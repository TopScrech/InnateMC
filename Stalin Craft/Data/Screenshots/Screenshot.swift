import Foundation

struct Screenshot: Hashable, Comparable {
    let path: URL
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.path)
    }
    
    static func < (lhs: Screenshot, rhs: Screenshot) -> Bool {
        lhs.path.lastPathComponent < rhs.path.lastPathComponent
    }
}

extension Array where Element == URL {
    func deserializeToScreenshots() -> [Screenshot] {
        self.filter {
            $0.isValidImageURL()
        }
        .map(Screenshot.init)
    }
}

extension URL {
    func isValidImageURL() -> Bool {
        let validExtensions = ["jpg", "jpeg", "png", "gif"]
        
        return validExtensions.contains(self.pathExtension.lowercased())
    }
}
