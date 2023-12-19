import FirebaseFirestore
import FirebaseFirestoreSwift

struct ItemDTO: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let name: String
    var done: Bool
    let dateCreated: Int
}

extension Item {
    var toDTO: ItemDTO {
        ItemDTO(id: documentId,
                name: name,
                done: done,
                dateCreated: dateCreated)
    }
}
