import FirebaseFirestore

public struct ItemDTO: Identifiable, Codable, Hashable {
	@DocumentID public var id: String?
	let name: String
	var done: Bool
	var index: Int
}
