import FirebaseFirestore
import FirebaseFirestoreSwift

public struct InvitationDTO: Identifiable, Codable, Hashable {
    @DocumentID public var id: String?
    public let ownerName: String
    public let ownerEmail: String
    public let listId: String
    public let listName: String
    public let invitedId: String
    public let index: Int
}
