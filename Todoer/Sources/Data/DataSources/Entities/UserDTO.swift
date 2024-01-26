import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserDTO: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var uuid: String
    var email: String?
    var displayName: String?
    var photoUrl: String?
    var provider: String
}

extension User {
    var toDomain: UserDTO {
        UserDTO(uuid: uuid,
                email: email,
                displayName: displayName,
                photoUrl: photoUrl,
                provider: provider)
    }
}
