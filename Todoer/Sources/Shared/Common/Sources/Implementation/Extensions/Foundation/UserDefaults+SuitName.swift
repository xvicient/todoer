import Foundation

extension UserDefaults {
    public static var appGroup: String {
        "group.com.xvicient.todoer"
    }

    public static var `default`: UserDefaults {
        guard let defaults = UserDefaults(suiteName: appGroup) else {
            Logger.log("No app group, using standard user defaults.")
            return .standard
        }
        return defaults
    }
}
