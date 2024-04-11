import Foundation

class InstancePreferences: ObservableObject, Codable {
    @Published var runtime = RuntimePreferences().invalidate()
}
