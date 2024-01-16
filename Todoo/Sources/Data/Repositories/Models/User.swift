import Foundation

struct User: Identifiable, Equatable, Hashable {
    let id = UUID()
    let documentId: String
    var uuid: String
    var email: String?
    var displayName: String?
    var photoUrl: String?
}

extension UserDTO {
    var toDomain: User {
        User(documentId: id ?? "",
             uuid: uuid,
             email: email,
             displayName: displayName,
             photoUrl: photoUrl)
    }
}
