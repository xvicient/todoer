import FirebaseFirestore
import FirebaseFirestoreSwift

protocol ListsDataSourceApi {
    func fetchLists(
        completion: @escaping (Result<[ListDTO], Error>) -> Void
    )
    func addList(
        with name: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteList(
        _ list: ListDTO
    )
}

struct ListsDataSource: ListsDataSourceApi {
    private let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
    private let listsCollection = Firestore.firestore().collection("lists")
    
    func fetchLists(
        completion: @escaping (Result<[ListDTO], Error>) -> Void
    ) {
        listsCollection
            .whereField("uuid", isEqualTo: uuid)
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
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            let document = listsCollection.document()
            let documentId = document.documentID
            let dto = ListDTO(id: documentId, name: name, uuid: uuid)
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
}
