import FirebaseFirestore

struct UserDTO: Identifiable, Codable, Hashable {
	@DocumentID var id: String?
	var uid: String
	var email: String?
	var displayName: String?
	var photoUrl: String?
	var provider: String
}

extension User {
	var toDomain: UserDTO {
		UserDTO(
			uid: uid,
			email: email,
			displayName: displayName,
			photoUrl: photoUrl,
			provider: provider
		)
	}
}
