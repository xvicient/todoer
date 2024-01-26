import Foundation

internal extension ListItems {
    enum Errors: Error, LocalizedError {
        case emptyItemName
        case unexpectedError
        
        var errorDescription: String? {
            switch self {
            case .emptyItemName:
                return "Item can't be empty."
            case .unexpectedError:
                return "Unexpected error."
            }
        }
    }
}
