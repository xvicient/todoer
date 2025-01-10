import Foundation

public struct User: Identifiable, Equatable, Hashable {
    public let id = UUID()
    public let documentId: String
	public var uid: String
    public var email: String?
    public var displayName: String?
    public var photoUrl: String?
    public var provider: String
}

extension UserDTO {
	var toDomain: User {
		User(
			documentId: id ?? "",
			uid: uid,
			email: email,
			displayName: displayName,
			photoUrl: photoUrl,
			provider: provider
		)
	}
}
