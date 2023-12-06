import FirebaseFirestore
import FirebaseFirestoreSwift

struct InvitationDTO: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let ownerName: String
    let ownerEmail: String
    let listId: String
    let listName: String
    let invitedId: String
    let dateCreated: Int
}

extension InvitationModel {
    var toDTO: InvitationDTO {
        InvitationDTO(id: documentId,
                      ownerName: ownerName,
                      ownerEmail: ownerEmail,
                      listId: listId,
                      listName: listName,
                      invitedId: invitedId,
                      dateCreated: dateCreated)
    }
}
