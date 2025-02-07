import Combine
import FirebaseFirestore
import Common

/// Protocol defining the API for interacting with todo lists data
protocol ListsDataSourceApi {
    /// Fetches lists for a specific user as a publisher
    /// - Parameter uid: User ID to fetch lists for
    /// - Returns: A publisher that emits arrays of list DTOs and can error
    func fetchLists(
        uid: String
    ) -> AnyPublisher<[ListDTO], Error>

    /// Adds a new list for a user
    /// - Parameters:
    ///   - name: Name of the list
    ///   - uid: User ID to create the list for
    /// - Returns: The created list DTO
    /// - Throws: Error if adding the list fails
    func addList(
        with name: String,
        uid: String
    ) async throws -> ListDTO

    /// Deletes a list
    /// - Parameter documentId: ID of the list document to delete
    /// - Throws: Error if the deletion fails
    func deleteList(
        _ documentId: String
    ) async throws

    /// Imports an existing list for a user
    /// - Parameters:
    ///   - id: ID of the list to import
    ///   - uid: User ID to import the list for
    /// - Throws: Error if the import fails
    func importList(
        id: String,
        uid: String
    ) async throws

    /// Updates an existing list
    /// - Parameter list: Updated list DTO
    /// - Returns: The updated list DTO
    /// - Throws: Error if the update fails
    func updateList(
        _ list: ListDTO
    ) async throws -> ListDTO

    /// Updates the sort order of lists
    /// - Parameter lists: Array of lists in their new order
    /// - Throws: Error if the update fails
    func sortLists(
        lists: [ListDTO]
    ) async throws

    /// Deletes lists matching specific search criteria
    /// - Parameter fields: Array of search fields to filter lists
    /// - Throws: Error if the deletion fails
    func deleteLists(
        with fields: [ListsDataSource.SearchField]
    ) async throws
    
    /// Deletes a list and all its items in a single transaction
    /// - Parameters:
    ///   - listId: ID of the list to delete
    ///   - itemsDocuments: Array of document snapshots for the list's items
    /// - Throws: Error if the deletion fails
    func deleteListAndAllItems(
        listId: String,
        itemsDocuments: [QueryDocumentSnapshot]
    ) async throws
}

/// Implementation of ListsDataSourceApi using Firebase Firestore
final class ListsDataSource: ListsDataSourceApi {

    /// Structure defining search criteria for lists
    struct SearchField {
        /// Keys that can be searched on
        enum Key: String {
            /// User ID field
            case uid
        }
        
        /// Types of filters that can be applied
        enum Filter {
            /// Array contains filter
            case arrayContains(String)
        }
        
        /// The key to search on
        let key: Key
        /// The filter to apply
        let filter: Filter

        /// Creates a new search field
        /// - Parameters:
        ///   - key: The key to search on
        ///   - filter: The filter to apply
        init(_ key: Key, _ filter: Filter) {
            self.key = key
            self.filter = filter
        }
    }

    /// Errors that can occur when working with lists
    private enum Errors: Error {
        /// The list DTO is missing required data
        case invalidDTO
        /// Failed to encode list data
        case encodingError
    }

    /// Registration for the Firestore snapshot listener
    private var snapshotListener: ListenerRegistration?
    /// Subject for publishing list updates
    private var listenerSubject: PassthroughSubject<[ListDTO], Error>?
    
    /// Removes the snapshot listener when the data source is deallocated
    deinit {
        snapshotListener?.remove()
        listenerSubject = nil
    }

    /// Reference to the Firestore lists collection
    private let listsCollection = Firestore.firestore().collection("lists")

    /// Fetches lists for a specific user as a publisher
    func fetchLists(
        uid: String
    ) -> AnyPublisher<[ListDTO], Error> {
        let subject = PassthroughSubject<[ListDTO], Error>()
        listenerSubject = subject

        snapshotListener =
            listsCollection
            .whereField("uid", arrayContains: uid)
            .addSnapshotListener { query, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                let lists =
                    query?.documents
                    .compactMap { try? $0.data(as: ListDTO.self) }
                    ?? []

                subject.send(lists)
            }

        return
            subject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Adds a new list for a user
    func addList(
        with name: String,
        uid: String
    ) async throws -> ListDTO {
        let dto = ListDTO(
            name: name,
            done: false,
            uid: [uid],
            index: -Date().milliseconds
        )
        return
            try await listsCollection
            .addDocument(from: dto)
            .getDocument()
            .data(as: ListDTO.self)
    }

    /// Deletes a list
    func deleteList(
        _ documentId: String
    ) async throws {
        try await listsCollection.document(documentId).delete()
    }

    /// Imports an existing list for a user
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

    /// Updates an existing list
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

    /// Updates the sort order of lists
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

    /// Deletes lists matching specific search criteria
    func deleteLists(
        with fields: [SearchField]
    ) async throws {
        try await listsQuery(with: fields)
            .getDocuments()
            .documents
            .forEach {
                listsCollection.document($0.documentID).delete()
            }
    }
    
    /// Deletes a list and all its items in a single transaction
    func deleteListAndAllItems(
        listId: String,
        itemsDocuments: [QueryDocumentSnapshot]
    ) async throws {
        let listDocument = listsCollection.document(listId)
        
        let _ = try await Firestore.firestore().runTransaction { (transaction, errorPointer) -> Any? in
            itemsDocuments.forEach {
                transaction.deleteDocument($0.reference)
            }
            
            transaction.deleteDocument(listDocument)
            return nil
        }
    }

    /// Creates a Firestore query based on the provided search fields
    /// - Parameter fields: Array of search fields to filter lists
    /// - Returns: A configured Firestore Query object
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
