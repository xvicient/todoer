import Foundation

/// A structure that represents an invitation to share a list with another user
/// Conforms to Identifiable for unique identification, Equatable for comparison,
/// Hashable for use in collections, and Sendable for concurrent operations
public struct Invitation: Identifiable, Equatable, Hashable, Sendable {
    /// A unique identifier for the invitation
    public let id = UUID()
    /// The document identifier in the database
    public let documentId: String
    /// The name of the user who owns the list
    public let ownerName: String
    /// The email of the user who owns the list
    public var ownerEmail: String
    /// The identifier of the list being shared
    public let listId: String
    /// The name of the list being shared
    public let listName: String
    /// The identifier of the user being invited
    public let invitedId: String
    /// The position of this invitation in the list of invitations
    public let index: Int
    
    /// Creates a new invitation instance
    /// - Parameters:
    ///   - documentId: The document identifier in the database
    ///   - ownerName: The name of the user who owns the list
    ///   - ownerEmail: The email of the user who owns the list
    ///   - listId: The identifier of the list being shared
    ///   - listName: The name of the list being shared
    ///   - invitedId: The identifier of the user being invited
    ///   - index: The position of this invitation in the list of invitations
    public init(
        documentId: String,
        ownerName: String,
        ownerEmail: String,
        listId: String,
        listName: String,
        invitedId: String,
        index: Int
    ) {
        self.documentId = documentId
        self.ownerName = ownerName
        self.ownerEmail = ownerEmail
        self.listId = listId
        self.listName = listName
        self.invitedId = invitedId
        self.index = index
    }
}
