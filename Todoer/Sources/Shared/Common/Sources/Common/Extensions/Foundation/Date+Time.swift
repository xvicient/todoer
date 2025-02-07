import Foundation

/// Extension providing time-related functionality to Date
public extension Date {
    /// Converts the date to milliseconds since the Unix epoch (January 1, 1970)
    /// - Returns: The number of milliseconds since the Unix epoch
    var milliseconds: Int {
        Int(timeIntervalSince1970 * 1000)
    }
}
