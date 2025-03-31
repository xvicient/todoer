import Foundation

public enum Errors: Error, LocalizedError {
    case unexpectedError
    
    public var errorDescription: String? {
        switch self {
        case .unexpectedError:
            return "Unexpected error."
        }
    }
    
    public static var `default`: String {
        Self.unexpectedError.localizedDescription
    }
}
