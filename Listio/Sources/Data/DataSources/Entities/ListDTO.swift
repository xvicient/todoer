import FirebaseFirestore
import FirebaseFirestoreSwift

struct ListDTO: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let name: String
    let done: Bool
    var uuid: [String]
    let dateCreated: Int
}

extension ListModel {
    var toDTO: ListDTO {
        ListDTO(id: documentId,
                name: name, 
                done: done,
                uuid: uuid,
                dateCreated: dateCreated)
    }
}
