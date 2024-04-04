import Foundation

public class UiPreferences: Codable, ObservableObject {
    @Published public var compactList = false
    @Published public var compactInstanceLogo = false
}
