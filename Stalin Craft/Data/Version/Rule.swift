struct Rule: Codable, Equatable {
    let action: ActionType
    let features: [String: Bool]?
    let os: OS?
    
    enum ActionType: String, Codable {
        case allow,
             disallow
    }
    
    struct OS: Codable, Equatable {
        let name: OSName?
        let version: String?
        let arch: String?
        
        enum OSName: String, Codable {
            case osx,
                 linux,
                 windows
        }
    }
    
    func matches(_ givenFeatures: [String: Bool]) -> Bool {
        var ok = true
        
        if let os {
            if let name = os.name {
                ok = ok && name == .osx
            }
#warning("Implement")
        }
        
        if let features {
            for (feature, value) in features where ok == true {
                ok = ok && (givenFeatures[feature] == value)
            }
        }
        
        return ok
    }
}

extension Array where Element == Rule {
    func allMatchRules(givenFeatures: [String: Bool]) -> Bool {
        var ok = true
        
        for rule in self where ok == true {
            ok = ok && rule.matches(givenFeatures)
        }
        
        return ok
    }
}
