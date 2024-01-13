import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

protocol ListsDataSourceApi {
    func fetchLists(
        uuid: String
    ) -> AnyPublisher<[ListDTO], Error>
    
    func addList(
        with name: String,
        uuid: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    func deleteList(
        _ documentId: String?
    )
    
    func toggleList(
        _ list: ListDTO
    ) async throws
    
    func importList(
        id: String,
        uuid: String
    ) async throws
    
    func updateList(
        _ list: ListDTO
    ) async throws -> ListDTO
}

final class ListsDataSource: ListsDataSourceApi {
    private enum Errors: Error {
        case invalidDTO
        case encodingError
    }
    
    private var snapshotListener: ListenerRegistration?
    private var listenerSubject: PassthroughSubject<[ListDTO], Error>?
    private var ignoreChanges = false
    
    deinit {
        snapshotListener?.remove()
        listenerSubject = nil
    }
    
    private let listsCollection = Firestore.firestore().collection("lists")
    
    
    func fetchLists(
        uuid: String
    ) -> AnyPublisher<[ListDTO], Error> {
        let subject = PassthroughSubject<[ListDTO], Error>()
        listenerSubject = subject
        
        snapshotListener = listsCollection
            .whereField("uuid", arrayContains: uuid)
            .addSnapshotListener { [weak self] query, error in
                guard let self = self else { return }
                
                guard !ignoreChanges else {
                    ignoreChanges = false
                    return
                }
                
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                let lists = query?.documents
                    .compactMap { try? $0.data(as: ListDTO.self) }
                ?? []
                
                subject.send(lists)
            }
        
        return subject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func addList(
        with name: String,
        uuid: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            let dto = ListDTO(name: name,
                              done: false,
                              uuid: [uuid],
                              dateCreated: Date().milliseconds)
            _ = try listsCollection.addDocument(from: dto)
            completion(.success(Void()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteList(
        _ documentId: String?
    ) {
        guard let id = documentId else { return }
        listsCollection.document(id).delete()
    }
    
    func importList(
        id: String,
        uuid: String
    ) async throws {
        let collection = listsCollection.document(id)
        if var dto = try? await collection.getDocument().data(as: ListDTO.self) {
            dto.uuid.append(uuid)
            _ = try? collection.setData(from: dto)
        } else {
            throw Errors.encodingError
        }
    }
    
    func toggleList(
        _ list: ListDTO
    ) async throws {
        guard let id = list.id else {
            throw Errors.invalidDTO
        }
        
        guard let encodedData = try? Firestore.Encoder().encode(list) else {
            throw Errors.encodingError
        }
        
        try await listsCollection.document(id).updateData(encodedData)
    }
    
    func updateList(
        _ list: ListDTO
    ) async throws -> ListDTO {
        guard let id = list.id else {
            throw Errors.invalidDTO
        }
        
        guard let encodedData = try? Firestore.Encoder().encode(list) else {
            throw Errors.encodingError
        }
        
        try await listsCollection.document(id).updateData(encodedData)
        return list
    }
}
