import Foundation

/// Structure providing access to application metadata and environment information
public struct AppInfo {
    /// The display name of the application as defined in the Info.plist
    public static let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    /// The version number of the application (e.g., "1.0.0")
    public static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    /// The build number of the application
    public static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    /// The current environment ("Debug" or "Release")
    public static let environment = isDebug() ? "Debug" : "Release"

    /// Determines if the app is running in debug mode
    /// - Returns: True if the app was built in debug configuration, false otherwise
    private static func isDebug() -> Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
}
