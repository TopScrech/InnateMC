import Foundation

public enum FileType: String, Codable, CaseIterable, InstanceData {
    case remote,
         local
}
