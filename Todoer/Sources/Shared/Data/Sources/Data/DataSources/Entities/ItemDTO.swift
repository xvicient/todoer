import FirebaseFirestore

struct ItemDTO: Identifiable, Codable, Hashable {
	@DocumentID var id: String?
	let name: String
	var done: Bool
	var index: Int
}
