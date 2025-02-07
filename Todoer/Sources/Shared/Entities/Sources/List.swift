import Foundation

/// A structure that represents a user's todo list
/// Conforms to Identifiable for unique identification, Equatable for comparison,
/// Hashable for use in collections, and Sendable for concurrent operations
public struct UserList: Identifiable, Equatable, Hashable, Sendable {
    /// A unique identifier for the list
    public let id: UUID
    /// The document identifier in the database
    public let documentId: String
    /// The name of the list
    public var name: String
    /// Indicates whether all items in the list are marked as done
    public var done: Bool
    /// Array of user IDs who have access to this list
    public var uid: [String]
    /// The position of this list in the user's lists
    public let index: Int
    
    /// Creates a new user list instance
    /// - Parameters:
    ///   - id: A unique identifier for the list
    ///   - documentId: The document identifier in the database
    ///   - name: The name of the list
    ///   - done: Whether all items in the list are marked as done
    ///   - uid: Array of user IDs who have access to this list
    ///   - index: The position of this list in the user's lists
    public init(
        id: UUID,
        documentId: String,
        name: String,
        done: Bool,
        uid: [String],
        index: Int
    ) {
        self.id = id
        self.documentId = documentId
        self.name = name
        self.done = done
        self.uid = uid
        self.index = index
    }
}
