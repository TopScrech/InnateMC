import Foundation

protocol InstanceCreator {
    func install() throws -> Instance
}
