import Foundation

public struct Arguments: Codable, Equatable {
    public static let none = Arguments(game: [], jvm: [])
    let game: [ArgumentElement]
    let jvm: [ArgumentElement]
    
    public static func +(lhs: Arguments, rhs: Arguments) -> Arguments {
        let combinedGame = lhs.game + rhs.game
        let combinedJvm = lhs.jvm + rhs.jvm
        
        return .init(game: combinedGame, jvm: combinedJvm)
    }
}
