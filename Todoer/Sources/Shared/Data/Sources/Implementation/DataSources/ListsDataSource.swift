import Combine
import Common
import FirebaseFirestore

protocol ListsDataSourceApi {
    func fetchLists(
        uid: String
    ) -> AnyPublisher<[ListDTO], Error>

    func addList(
        with name: String,
        uid: String
    ) async throws -> ListDTO

    func addLists(
        names: [String],
        uid: String
    ) async throws -> [ListDTO]

    func deleteLists(
        with fields: [ListsDataSource.SearchField]
    ) async throws

    func deleteListAndAllItems(
        listId: String,
        itemsDocuments: [QueryDocumentSnapshot]
    ) async throws

    func importList(
        id: String,
        uid: String
    ) async throws

    func updateList(
        _ list: ListDTO
    ) async throws -> ListDTO

    func sortLists(
        lists: [ListDTO]
    ) async throws
}

final class ListsDataSource: ListsDataSourceApi {

    struct SearchField {
        enum Key: String {
            case uid
        }
        enum Filter {
            case arrayContains(String)
        }
        let key: Key
        let filter: Filter

        init(_ key: Key, _ filter: Filter) {
            self.key = key
            self.filter = filter
        }
    }

    private enum Errors: Error {
        case invalidDTO
        case encodingError
        case addListError
    }

    private let listsCollection = Firestore.firestore().collection("lists")
    
    public var snapshotState = SnapshotState()

    func fetchLists(
        uid: String
    ) -> AnyPublisher<[ListDTO], Error> {
        listsCollection
            .whereField("uid", arrayContains: uid)
            .snapshotPublisher(skipWith: snapshotState)
            .filter { !$0.metadata.hasPendingWrites }
            .map { snapshot in
                snapshot.documents.compactMap { document -> ListDTO? in
                    guard var dto = try? document.data(as: ListDTO.self) else { return nil }
                    dto.id = document.documentID
                    return dto
                }
            }
            .eraseToAnyPublisher()
    }

    func addList(
        with name: String,
        uid: String
    ) async throws -> ListDTO {
        let docRef = try listsCollection
            .addDocument(from: name.toDTO(uid))
        let document = try await docRef.getDocument()
        guard var result = try? document.data(as: ListDTO.self) else {
            throw Errors.invalidDTO
        }
        result.id = document.documentID
        return result
    }

    func addLists(
        names: [String],
        uid: String
    ) async throws -> [ListDTO] {
        let batch = Firestore.firestore().batch()

        let lists =
            try names
            .map {
                var list = $0.toDTO(uid)
                let document = self.listsCollection.document()
                try batch.setData(from: list, forDocument: document)
                list.id = document.documentID
                return list
            }

        try await batch.commit()

        return lists
    }

    func importList(
        id: String,
        uid: String
    ) async throws {
        let collection = listsCollection.document(id)
        if var dto = try? await collection.getDocument().data(as: ListDTO.self) {
            dto.uid.append(uid)
            try? collection.setData(from: dto)
        }
        else {
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

        try lists.forEach {
            guard let id = $0.id else {
                return
            }

            let encodedData = try Firestore.Encoder().encode($0)
            productsBatch.updateData(
                encodedData,
                forDocument: listsCollection.document(id)
            )
        }

        try await productsBatch.commit()
    }

    func deleteLists(
        with fields: [SearchField]
    ) async throws {
        snapshotState.isStopped = true
        
        try await listsQuery(with: fields)
            .getDocuments()
            .documents
            .forEach {
                listsCollection.document($0.documentID).delete()
            }
    }

    func deleteListAndAllItems(
        listId: String,
        itemsDocuments: [QueryDocumentSnapshot]
    ) async throws {
        let listDocument = listsCollection.document(listId)

        let _ = try await Firestore.firestore().runTransaction {
            (transaction, errorPointer) -> Any? in
            itemsDocuments.forEach {
                transaction.deleteDocument($0.reference)
            }

            transaction.deleteDocument(listDocument)
            return nil
        }
    }

    private func listsQuery(
        with fields: [SearchField]
    ) -> Query {
        var query: Query = listsCollection

        fields.forEach {
            switch $0.filter {
            case .arrayContains(let value):
                query = query.whereField($0.key.rawValue, arrayContains: value)
            }
        }

        return query
    }
}

extension String {
    fileprivate func toDTO(_ uid: String) -> ListDTO {
        ListDTO(
            name: self,
            done: false,
            uid: [uid],
            index: -Date().milliseconds
        )
    }
}
