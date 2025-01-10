import Foundation

public struct Logger {
    public static func log(_ message: String, function: String = #function) {
		let timestamp = DateFormatter.localizedString(
			from: Date(),
			dateStyle: .short,
			timeStyle: .medium
		)
		debugPrint("\(timestamp) - \(function): \(message)")
	}
}
