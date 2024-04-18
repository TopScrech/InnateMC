import Foundation

struct World: Hashable {
    let folder: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(folder)
    }
}
