import Foundation

public struct Artifact: Codable, Equatable {
    public static let none = Artifact(sha1: "", size: 0, url: URL(string: "/")!)
    
    var sha1: String
    var size: Int
    var url: URL
}
