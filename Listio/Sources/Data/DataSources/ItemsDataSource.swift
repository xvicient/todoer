import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

protocol ItemsDataSourceApi {
    func fetchItems(
        listId: String
    ) -> AnyPublisher<[ItemDTO], Error>
    
    func addItem(
        with name: String,
        listId: String
    ) async throws -> ItemDTO
    
    func deleteItem(
        itemId: String,
        listId: String
    ) async throws
    
    func updateItem(
        item: ItemDTO,
        listId: String
    )  async throws -> ItemDTO
    
    func toogleAllItemsBatch(
        listId: String?,
        done: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class ItemsDataSource: ItemsDataSourceApi {
    private enum Errors: Error {
        case invalidDTO
        case encodingError
    }
    
    private var snapshotListener: ListenerRegistration?
    private var listenerSubject = PassthroughSubject<[ItemDTO], Error>()
    
    deinit {
        snapshotListener?.remove()
    }
    
    private func itemsCollection(listId: String) -> CollectionReference {
        Firestore.firestore().collection("lists").document(listId).collection("items")
    }
    
    func fetchItems(
        listId: String
    ) -> AnyPublisher<[ItemDTO], Error> {
        snapshotListener = itemsCollection(listId: listId)
            .addSnapshotListener { [weak self] query, error in
                guard let self = self else { return }
                
                if let error = error {
                    listenerSubject.send(completion: .failure(error))
                    return
                }
                
                let products = query?.documents
                    .compactMap { try? $0.data(as: ItemDTO.self) }
                ?? []
                
                listenerSubject.send(products)
            }
        
        return listenerSubject.eraseToAnyPublisher()
        
    }
    
    func addItem(
        with name: String,
        listId: String
    ) async throws -> ItemDTO {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let collection = itemsCollection(listId: listId)
                let dto = ItemDTO(name: name,
                                  done: false,
                                  dateCreated: Date().milliseconds)
                _ = try collection.addDocument(from: dto)
                continuation.resume(returning: dto)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func deleteItem(
        itemId: String,
        listId: String
    ) async throws {
        try await itemsCollection(listId: listId).document(itemId).delete()
    }
    
    func updateItem(
        item: ItemDTO,
        listId: String
    )  async throws -> ItemDTO {
        guard let id = item.id else {
            throw Errors.invalidDTO
        }
        
        guard let encodedData = try? Firestore.Encoder().encode(item) else {
            throw Errors.encodingError
        }
        
        try await itemsCollection(listId: listId).document(id).updateData(encodedData)
        return item
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
