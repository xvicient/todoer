import FirebaseFirestore
import FirebaseFirestoreSwift

protocol ListsDataSourceApi {
    func fetchLists(
        uuid: String,
        completion: @escaping (Result<[ListDTO], Error>) -> Void
    )
    func addList(
        with name: String,
        uuid: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteList(
        _ list: ListDTO
    )
}

final class ListsDataSource: ListsDataSourceApi {
    private let listsCollection = Firestore.firestore().collection("lists")
    
    func fetchLists(
        uuid: String,
        completion: @escaping (Result<[ListDTO], Error>) -> Void
    ) {
        listsCollection
            .whereField("uuid", arrayContains: uuid)
            .addSnapshotListener { query, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let lists = query?.documents
                    .compactMap { try? $0.data(as: ListDTO.self) }
                ?? []
                completion(.success(lists))
            }
    }
    
    func addList(
        with name: String,
        uuid: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            let document = listsCollection.document()
            let documentId = document.documentID
            let dto = ListDTO(id: documentId, name: name, done: false, uuid: [uuid])
            _ = try listsCollection.addDocument(from: dto)
            completion(.success(Void()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteList(
        _ list: ListDTO
    ) {
        guard let id = list.id else { return }
        listsCollection.document(id).delete()
    }
    
    func importList(
        id: String,
        uuid: String
    ) {
        listsCollection
            .whereField("listId", isEqualTo: id)
            .getDocuments { [weak self] query, error in
                guard error == nil else { return }
                
                query?.documents
                    .forEach {
                        guard var dto = try? $0.data(as: ListDTO.self) else { return }
                        dto.uuid.append(uuid)
                        do {
                            _ = try self?.listsCollection.document(id).setData(from: dto)
                        } catch {
                            print(error)
                        }
                    }
            }
    }
}
