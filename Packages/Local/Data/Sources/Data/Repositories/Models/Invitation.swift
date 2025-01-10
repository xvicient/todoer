import Foundation

public struct Invitation: Identifiable, Equatable, Hashable {
    public let id = UUID()
    public let documentId: String
    public let ownerName: String
    public var ownerEmail: String
    public let listId: String
    public let listName: String
    public let invitedId: String
    public let index: Int
}
