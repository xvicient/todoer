import FirebaseFirestore

struct UserDTO: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var uid: String
    var email: String?
    var displayName: String?
    var photoUrl: String?
    var provider: String
}
