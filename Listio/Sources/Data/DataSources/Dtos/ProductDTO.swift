import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProductDTO: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let name: String
    var done: Bool
    let dateCreated: Int
}

extension ProductModel {
    var toDTO: ProductDTO {
        ProductDTO(id: documentId,
                   name: name,
                   done: done,
                   dateCreated: dateCreated)
    }
}
