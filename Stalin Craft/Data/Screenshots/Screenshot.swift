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

extension URL {
    func isValidImageURL() -> Bool {
        let validExtensions = ["jpg", "jpeg", "png", "gif"]
        
        return validExtensions.contains(self.pathExtension.lowercased())
    }
}
