import FirebaseAuth

public struct AuthDataDTO {
    public let uid: String
    public let email: String?
    public let displayName: String?
    public let photoUrl: String?
    public let isAnonymous: Bool

	init(
        user: FirebaseAuth.User,
        email: String? = nil,
        displayName: String? = nil
    ) {
		self.uid = user.uid
		self.email = email ?? user.email
		self.photoUrl = user.photoURL?.absoluteString
		self.isAnonymous = user.isAnonymous
		self.displayName = displayName ?? user.displayName
	}
}
