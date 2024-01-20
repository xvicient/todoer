import FirebaseFirestore
import FirebaseFirestoreSwift

struct InvitationDTO: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let ownerName: String
    let ownerEmail: String
    let listId: String
    let listName: String
    let invitedId: String
    let index: Int
}
