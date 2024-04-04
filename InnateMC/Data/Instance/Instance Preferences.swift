import Foundation

public class InstancePreferences: ObservableObject, Codable {
    @Published public var runtime = RuntimePreferences().invalidate()
}
