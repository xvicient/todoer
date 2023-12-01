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
        _ documentId: String?,
        listId: String
    )
    func toggleProduct(
        _ product: ProductDTO,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func toogleAllProductsBatch(
        listId: String?,
        done: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
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
            _ = try collection.addDocument(from: ProductDTO(name: name,
                                                            done: false,
                                                            dateCreated: Date().milliseconds))
            completion(.success(Void()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteProduct(
        _ documentId: String?,
        listId: String
    ) {
        guard let id = documentId else { return }
        productsCollection(listId: listId).document(id).delete()
    }
    
    func toggleProduct(
        _ product: ProductDTO,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let id = product.id,
        let encodedData = try? Firestore.Encoder().encode(product) else { return }
        
        productsCollection(listId: listId).document(id).updateData(encodedData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(Void()))
            }
        }
    }
    
    func toogleAllProductsBatch(
        listId: String?,
        done: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let listId = listId else { return }
        let collection = productsCollection(listId: listId)
        
        collection.getDocuments { query, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let productsBatch = Firestore.firestore().batch()
            
            query?.documents
                .forEach {
                    guard var dto = try? $0.data(as: ProductDTO.self) else { return }
                    dto.done = done
                    
                    if let encodedData = try? Firestore.Encoder().encode(dto) {
                        productsBatch.updateData(
                            encodedData,
                            forDocument: collection.document($0.documentID)
                        )
                    }
                }
            
            productsBatch.commit { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(Void()))
                }
            }
        }
    }
}
