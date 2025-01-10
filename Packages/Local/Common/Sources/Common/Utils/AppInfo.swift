import Foundation

public struct AppInfo {
    public static let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    public static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    public static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    public static let environment = isDebug() ? "Debug" : "Release"

	private static func isDebug() -> Bool {
		#if DEBUG
			return true
		#else
			return false
		#endif
	}
}
