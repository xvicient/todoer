import Foundation

/// Extension providing error code functionality to Error
public extension Error {
    /// Gets the numeric error code from the error
    /// Converts the error to NSError to access its code property
    /// - Returns: The numeric error code
    var code: Int {
        (self as NSError).code
    }
}
