import Foundation

struct Invitation: Identifiable, Equatable, Hashable {
	let id = UUID()
	let documentId: String
	let ownerName: String
	var ownerEmail: String
	let listId: String
	let listName: String
	let invitedId: String
	let index: Int
}
