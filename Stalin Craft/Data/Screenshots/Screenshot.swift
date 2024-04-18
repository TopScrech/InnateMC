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
