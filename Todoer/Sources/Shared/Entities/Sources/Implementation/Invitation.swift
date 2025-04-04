import Foundation

public struct Invitation: Identifiable, Equatable, Hashable, Sendable {
    private enum Errors: Error {
        case invalidId
    }
    public let id: String
    public let ownerName: String
    public var ownerEmail: String
    public let listId: String
    public let listName: String
    public let invitedId: String
    public let index: Int

    public init(
        id: String?,
        ownerName: String,
        ownerEmail: String,
        listId: String,
        listName: String,
        invitedId: String,
        index: Int
    ) throws {
        guard let id else {
            throw Errors.invalidId
        }
        self.id = id
        self.ownerName = ownerName
        self.ownerEmail = ownerEmail
        self.listId = listId
        self.listName = listName
        self.invitedId = invitedId
        self.index = index
    }
}
