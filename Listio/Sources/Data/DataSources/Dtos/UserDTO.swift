import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserDTO: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var uuid: String
    var email: String?
    var displayName: String?
}
