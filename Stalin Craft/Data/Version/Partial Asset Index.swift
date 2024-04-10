import Foundation

public struct PartialAssetIndex: Codable, Equatable {
    public static let none = PartialAssetIndex(id: "none", sha1: "", url: "")
    public let id: String
    public let sha1: String
    public let url: String
    
    public func `default`(fallback: PartialAssetIndex) -> PartialAssetIndex {
        self == .none ? fallback : self
    }
}
