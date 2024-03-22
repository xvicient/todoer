import FirebaseFirestore
import FirebaseFirestoreSwift

public struct UserDTO: Identifiable, Codable, Hashable {
	@DocumentID public var id: String?
	public var uid: String
	public var email: String?
	public var displayName: String?
	public var photoUrl: String?
	public var provider: String
}
