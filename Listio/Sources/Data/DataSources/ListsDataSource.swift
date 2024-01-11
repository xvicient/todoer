import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

protocol ListsDataSourceApi {
    func fetchLists(
        uuid: String
    ) -> AnyPublisher<[ListDTO], Error>
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
        _ documentId: String?
    )
    
    func toggleList(
        _ list: ListDTO,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    func importList(
        id: String,
        uuid: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
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
        uuid: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        listsCollection.document(id).getDocument() { [weak self] query, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                guard var dto = try? query?.data(as: ListDTO.self) else {
                    return
                }
                dto.uuid.append(uuid)
                _ = try self?.listsCollection.document(id).setData(from: dto)
                completion(.success(Void()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func toggleList(
        _ list: ListDTO,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let id = list.id,
        let encodedData = try? Firestore.Encoder().encode(list) else { return }
        
        listsCollection.document(id).updateData(encodedData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(Void()))
            }
        }
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
