import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProductDTO: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let name: String
    let done: Bool
}
