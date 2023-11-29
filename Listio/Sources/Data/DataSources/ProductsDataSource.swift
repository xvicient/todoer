import FirebaseFirestore
import FirebaseFirestoreSwift

protocol ProductsDataSourceApi {
    func fetchProducts(
        listId: String,
        completion: @escaping (Result<[ProductDTO], Error>) -> Void
    )
    func addProduct(
        with name: String,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteProduct(
        _ product: ProductDTO,
        listId: String
    )
}

final class ProductsDataSource: ProductsDataSourceApi {
    private func productsCollection(listId: String) -> CollectionReference {
        Firestore.firestore().collection("lists").document(listId).collection("products")
    }
    
    func fetchProducts(
        listId: String,
        completion: @escaping (Result<[ProductDTO], Error>) -> Void
    ) {
        productsCollection(listId: listId)
            .addSnapshotListener { query, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let products = query?.documents
                    .compactMap { try? $0.data(as: ProductDTO.self) }
                ?? []
                completion(.success(products))
            }
    }
    
    func addProduct(
        with name: String,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            let collection = productsCollection(listId: listId)
            let documentId = collection.document().documentID
            _ = try collection.addDocument(from: ProductDTO(id: documentId, 
                                                            name: name,
                                                            done: false,
                                                            dateCreated: Timestamp(date: Date())))
            completion(.success(Void()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteProduct(
        _ product: ProductDTO,
        listId: String
    ) {
        guard let id = product.id else { return }
        productsCollection(listId: listId).document(id).delete()
    }
}
