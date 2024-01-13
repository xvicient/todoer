import Foundation

struct Invitation: Identifiable, Equatable, Hashable {
    let id = UUID()
    let documentId: String
    let ownerName: String
    let ownerEmail: String
    let listId: String
    let listName: String
    let invitedId: String
    let dateCreated: Int
}
