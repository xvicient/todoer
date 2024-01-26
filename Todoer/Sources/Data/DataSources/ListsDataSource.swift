import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

protocol ListsDataSourceApi {
    func fetchLists(
        uuid: String
    ) -> AnyPublisher<[ListDTO], Error>
    
    func addList(
        with name: String,
        uuid: String
    ) async throws -> ListDTO
    
    func deleteList(
        _ documentId: String
    ) async throws
    
    func importList(
        id: String,
        uuid: String
    ) async throws
    
    func updateList(
        _ list: ListDTO
    ) async throws -> ListDTO
    
    func sortLists(
        lists: [ListDTO]
    ) async throws
}

final class ListsDataSource: ListsDataSourceApi {
    private enum Errors: Error {
        case invalidDTO
        case encodingError
    }
    
    private var snapshotListener: ListenerRegistration?
    private var listenerSubject: PassthroughSubject<[ListDTO], Error>?
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
            .addSnapshotListener { query, error in
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
        uuid: String
    ) async throws -> ListDTO {
        let dto = ListDTO(name: name,
                          done: false,
                          uuid: [uuid],
                          index: Date().milliseconds)
        return try await listsCollection
            .addDocument(from: dto)
            .getDocument()
            .data(as: ListDTO.self)
    }
    
    func deleteList(
        _ documentId: String
    ) async throws {
        try await listsCollection.document(documentId).delete()
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
    
    func sortLists(
        lists: [ListDTO]
    ) async throws {
        let productsBatch = Firestore.firestore().batch()
        
        try lists.enumerated().forEach { index, list in
            guard let id = list.id else {
                return
            }
            var mutableList = list
            mutableList.index = index
            
            let encodedData = try Firestore.Encoder().encode(mutableList)
            productsBatch.updateData(
                encodedData,
                forDocument: listsCollection.document(id)
            )
        }
        
        try await productsBatch.commit()
    }
}
