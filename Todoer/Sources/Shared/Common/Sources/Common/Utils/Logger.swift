import Foundation

/// A simple logging utility for debugging purposes
public struct Logger {
    /// Logs a message with timestamp and function information
    /// - Parameters:
    ///   - message: The message to log
    ///   - function: The function name where the log was called (automatically provided by default)
    public static func log(_ message: String, function: String = #function) {
        let timestamp = DateFormatter.localizedString(
            from: Date(),
            dateStyle: .short,
            timeStyle: .medium
        )
        debugPrint("\(timestamp) - \(function): \(message)")
    }
}
