import Foundation

struct ProductModel: Identifiable, Equatable, Hashable {
    let id = UUID()
    let documentId: String
    let name: String
    var done: Bool
    let dateCreated: Int
}

extension ProductDTO {
    var toDomain: ProductModel {
        ProductModel(documentId: id ?? "",
                     name: name,
                     done: done,
                     dateCreated: dateCreated)
    }
}
