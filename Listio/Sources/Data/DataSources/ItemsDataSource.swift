import FirebaseFirestore
import FirebaseFirestoreSwift

protocol ItemsDataSourceApi {
    func fetchItems(
        listId: String,
        completion: @escaping (Result<[ItemDTO], Error>) -> Void
    )
    func addItem(
        with name: String,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteItem(
        _ documentId: String?,
        listId: String
    )
    func toggleItem(
        _ item: ItemDTO,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func toogleAllItemsBatch(
        listId: String?,
        done: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class ItemsDataSource: ItemsDataSourceApi {
    private func itemsCollection(listId: String) -> CollectionReference {
        Firestore.firestore().collection("lists").document(listId).collection("items")
    }
    
    func fetchItems(
        listId: String,
        completion: @escaping (Result<[ItemDTO], Error>) -> Void
    ) {
        itemsCollection(listId: listId)
            .addSnapshotListener { query, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let products = query?.documents
                    .compactMap { try? $0.data(as: ItemDTO.self) }
                ?? []
                completion(.success(products))
            }
    }
    
    func addItem(
        with name: String,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            let collection = itemsCollection(listId: listId)
            _ = try collection.addDocument(from: ItemDTO(name: name,
                                                            done: false,
                                                            dateCreated: Date().milliseconds))
            completion(.success(Void()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteItem(
        _ documentId: String?,
        listId: String
    ) {
        guard let id = documentId else { return }
        itemsCollection(listId: listId).document(id).delete()
    }
    
    func toggleItem(
        _ item: ItemDTO,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let id = item.id,
        let encodedData = try? Firestore.Encoder().encode(item) else { return }
        
        itemsCollection(listId: listId).document(id).updateData(encodedData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(Void()))
            }
        }
    }
    
    func toogleAllItemsBatch(
        listId: String?,
        done: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let listId = listId else { return }
        let collection = itemsCollection(listId: listId)
        
        collection.getDocuments { query, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let productsBatch = Firestore.firestore().batch()
            
            query?.documents
                .forEach {
                    guard var dto = try? $0.data(as: ItemDTO.self) else { return }
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
