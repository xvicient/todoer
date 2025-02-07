import Entities
import Foundation

/// Mock data generator for UserList entities
public struct ListMock {
    /// Returns a single mock list
    /// Convenience accessor for the first list in a collection of one
    public static var list: UserList {
        lists(1).first!
    }

    /// Generates an array of mock lists
    /// - Parameter count: Number of mock lists to generate
    /// - Returns: Array of mock lists with sequential IDs and indices
    static func lists(_ count: Int) -> [UserList] {
        (0..<count).map {
            UserList(
                id: UUID(),
                documentId: String($0),
                name: String($0),
                done: false,
                uid: [String($0)],
                index: $0
            )
        }
    }
}
