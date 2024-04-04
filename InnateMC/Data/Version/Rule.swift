import Foundation

public struct Rule: Codable, Equatable {
    let action: ActionType
    let features: [String: Bool]?
    let os: OS?
    
    public enum ActionType: String, Codable, Equatable {
        case allow,
             disallow
    }
    
    public struct OS: Codable, Equatable {
        let name: OSName?
        let version: String?
        let arch: String?
        
        public enum OSName: String, Codable, Equatable {
            case osx,
                 linux,
                 windows
        }
    }
    
    public func matches(givenFeatures: [String:Bool]) -> Bool {
        var ok = true
        
        if let os {
            if let name = os.name {
                ok = ok && name == .osx
            }
            // TODO: implement
        }
        
        if let features = features {
            for (feature, value) in features where ok == true {
                ok = ok && (givenFeatures[feature] == value)
            }
        }
        
        return ok
    }
}

extension Array where Element == Rule {
    func allMatchRules(givenFeatures: [String:Bool]) -> Bool {
        var ok = true
        
        for rule in self where ok == true {
            ok = ok && rule.matches(givenFeatures: givenFeatures)
        }
        
        return ok
    }
}
