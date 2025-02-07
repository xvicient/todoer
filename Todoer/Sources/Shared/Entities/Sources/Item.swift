import Foundation

/// A structure that represents a todo item in a list
/// Conforms to Identifiable for unique identification, Equatable for comparison,
/// Hashable for use in collections, and Sendable for concurrent operations
public struct Item: Identifiable, Equatable, Hashable, Sendable {
    /// A unique identifier for the item
    public let id: UUID
    /// The document identifier in the database
    public let documentId: String
    /// The name or description of the todo item
    public var name: String
    /// Indicates whether the item is marked as done
    public var done: Bool
    /// The position of this item in the list
    public let index: Int
    
    /// Creates a new todo item instance
    /// - Parameters:
    ///   - id: A unique identifier for the item
    ///   - documentId: The document identifier in the database
    ///   - name: The name or description of the todo item
    ///   - done: Whether the item is marked as done
    ///   - index: The position of this item in the list
    public init(
        id: UUID,
        documentId: String,
        name: String,
        done: Bool,
        index: Int
    ) {
        self.id = id
        self.documentId = documentId
        self.name = name
        self.done = done
        self.index = index
    }
}
