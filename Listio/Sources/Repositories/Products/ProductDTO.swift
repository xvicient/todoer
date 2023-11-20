import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProductDTO: Identifiable, Decodable, Encodable, Hashable {
    @DocumentID var id: String?
    let name: String
    let uuid: String
}
