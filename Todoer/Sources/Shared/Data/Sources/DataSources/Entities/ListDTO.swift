import FirebaseFirestore

struct ListDTO: Identifiable, Codable, Hashable {
	@DocumentID var id: String?
	let name: String
	let done: Bool
	var uid: [String]
	var index: Int
}
