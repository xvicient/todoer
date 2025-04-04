import FirebaseFirestore

struct InvitationDTO: Identifiable, Codable, Hashable {
    var id: String?
    let ownerName: String
    let ownerEmail: String
    let listId: String
    let listName: String
    let invitedId: String
    let index: Int
}
