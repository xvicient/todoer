import FirebaseAuth

public struct AuthDataDTO {
	public let uid: String
	public var email: String?
	public var displayName: String?
	public let photoUrl: String?
	public let isAnonymous: Bool

	init(user: FirebaseAuth.User) {
		self.uid = user.uid
		self.email = user.email
		self.photoUrl = user.photoURL?.absoluteString
		self.isAnonymous = user.isAnonymous
		self.displayName = user.displayName
	}
}
