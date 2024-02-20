import Foundation

struct AppInfo {
	static let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
	static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
	static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
	static let environment = isDebug() ? "Debug" : "Release"

	private static func isDebug() -> Bool {
		#if DEBUG
			return true
		#else
			return false
		#endif
	}
}
