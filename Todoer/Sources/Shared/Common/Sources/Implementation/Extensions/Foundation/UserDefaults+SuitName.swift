import Foundation

public extension UserDefaults {
    static var appGroup: String {
        "group.com.xvicient.todoer"
    }
    
    static var `default`: UserDefaults {
        guard let defaults = UserDefaults(suiteName: appGroup) else {
            Logger.log("No app group, using standard user defaults.")
            return .standard
        }
        return defaults
    }
}
