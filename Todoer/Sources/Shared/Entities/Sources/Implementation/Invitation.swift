import Foundation

public struct Invitation: Identifiable, Equatable, Hashable, Sendable {
    public let id = UUID()
    public let documentId: String
    public let ownerName: String
    public var ownerEmail: String
    public let listId: String
    public let listName: String
    public let invitedId: String
    public let index: Int

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
