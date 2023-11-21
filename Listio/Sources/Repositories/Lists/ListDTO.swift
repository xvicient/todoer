import FirebaseFirestore
import FirebaseFirestoreSwift

struct ListDTO: Identifiable, Decodable, Encodable, Hashable {
    @DocumentID var id: String?
    let name: String
    let uuid: String
}
