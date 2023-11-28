import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserDTO: Identifiable, Decodable, Encodable, Hashable {
    @DocumentID var id: String?
    var uuid: String
    var email: String?
}
