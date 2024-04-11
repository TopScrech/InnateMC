import Foundation

enum FileType: String, Codable, CaseIterable, InstanceData {
    case remote,
         local
}
