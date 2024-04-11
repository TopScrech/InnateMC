import Foundation

struct Artifact: Codable, Equatable {
    static let none = Artifact(sha1: "", size: 0, url: URL(string: "/")!)
    
    var sha1: String
    var size: Int
    var url: URL
}
