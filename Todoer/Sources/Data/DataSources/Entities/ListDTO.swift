import FirebaseFirestore
import FirebaseFirestoreSwift

struct ListDTO: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let name: String
    let done: Bool
    var uuid: [String]
    var dateCreated: Int
}
