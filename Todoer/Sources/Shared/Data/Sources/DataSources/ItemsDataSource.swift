import Combine
import FirebaseFirestore
import Common

/// Protocol defining the API for interacting with todo items data
public protocol ItemsDataSourceApi {
    /// Retrieves all document snapshots for items in a list
    /// - Parameter listId: ID of the list to get items from
    /// - Returns: Array of Firestore document snapshots
    /// - Throws: Error if the retrieval fails
    func documents(
        listId: String
    ) async throws -> [QueryDocumentSnapshot]
    
    /// Fetches items from a list as a publisher
    /// - Parameter listId: ID of the list to fetch items from
    /// - Returns: A publisher that emits arrays of item DTOs and can error
    func fetchItems(
        listId: String
    ) -> AnyPublisher<[ItemDTO], Error>

    /// Adds a new item to a list
    /// - Parameters:
    ///   - name: Name of the item
    ///   - listId: ID of the list to add the item to
    /// - Returns: The created item DTO
    /// - Throws: Error if adding the item fails
    func addItem(
        with name: String,
        listId: String
    ) async throws -> ItemDTO

    /// Deletes an item from a list
    /// - Parameters:
    ///   - itemId: ID of the item to delete
    ///   - listId: ID of the list containing the item
    /// - Throws: Error if the deletion fails
    func deleteItem(
        itemId: String,
        listId: String
    ) async throws

    /// Updates an existing item in a list
    /// - Parameters:
    ///   - item: Updated item DTO
    ///   - listId: ID of the list containing the item
    /// - Returns: The updated item DTO
    /// - Throws: Error if the update fails
    func updateItem(
        item: ItemDTO,
        listId: String
    ) async throws -> ItemDTO

    /// Toggles the completion status of all items in a list
    /// - Parameters:
    ///   - listId: ID of the list containing the items
    ///   - done: New completion status to set
    /// - Throws: Error if the update fails
    func toogleAllItems(
        listId: String,
        done: Bool
    ) async throws

    /// Updates the sort order of items in a list
    /// - Parameters:
    ///   - items: Array of items in their new order
    ///   - listId: ID of the list containing the items
    /// - Throws: Error if the update fails
    func sortItems(
        items: [ItemDTO],
        listId: String
    ) async throws
}

/// Implementation of ItemsDataSourceApi using Firebase Firestore
public final class ItemsDataSource: ItemsDataSourceApi {
    /// Errors that can occur when working with items
    private enum Errors: Error {
        /// The item DTO is missing required data
        case invalidDTO
        /// Failed to encode item data
        case encodingError
    }

    /// Registration for the Firestore snapshot listener
    private var snapshotListener: ListenerRegistration?
    /// Subject for publishing item updates
    private var listenerSubject: PassthroughSubject<[ItemDTO], Error>?

    /// Creates a new items data source
    public init() {}
    
    /// Removes the snapshot listener when the data source is deallocated
    deinit {
        snapshotListener?.remove()
        listenerSubject = nil
    }

    /// Gets a reference to the items collection for a specific list
    /// - Parameter listId: ID of the list to get items from
    /// - Returns: Firestore collection reference
    private func itemsCollection(
        listId: String
    ) -> CollectionReference {
        Firestore.firestore().collection("lists").document(listId).collection("items")
    }
    
    /// Retrieves all document snapshots for items in a list
    public func documents(
        listId: String
    ) async throws -> [QueryDocumentSnapshot] {
        try await itemsCollection(listId: listId).getDocuments().documents
    }

    /// Fetches items from a list as a publisher
    public func fetchItems(
        listId: String
    ) -> AnyPublisher<[ItemDTO], Error> {
        let subject = PassthroughSubject<[ItemDTO], Error>()
        listenerSubject = subject

        snapshotListener = itemsCollection(listId: listId)
            .addSnapshotListener { query, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                let products =
                    query?.documents
                    .compactMap { try? $0.data(as: ItemDTO.self) }
                    ?? []

                subject.send(products)
            }

        return
            subject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Adds a new item to a list
    public func addItem(
        with name: String,
        listId: String
    ) async throws -> ItemDTO {
        do {
            let dto = ItemDTO(
                name: name,
                done: false,
                index: -Date().milliseconds
            )
            return try await itemsCollection(listId: listId)
                .addDocument(from: dto)
                .getDocument()
                .data(as: ItemDTO.self)
        }
        catch {
            throw (error)
        }
    }

    /// Deletes an item from a list
    public func deleteItem(
        itemId: String,
        listId: String
    ) async throws {
        try await itemsCollection(listId: listId).document(itemId).delete()
    }

    /// Updates an existing item in a list
    public func updateItem(
        item: ItemDTO,
        listId: String
    ) async throws -> ItemDTO {
        guard let id = item.id else {
            throw Errors.invalidDTO
        }

        guard let encodedData = try? Firestore.Encoder().encode(item) else {
            throw Errors.encodingError
        }

        try await itemsCollection(listId: listId).document(id).updateData(encodedData)
        return item
    }

    /// Toggles the completion status of all items in a list
    public func toogleAllItems(
        listId: String,
        done: Bool
    ) async throws {
        let collection = itemsCollection(listId: listId)
        let batch = Firestore.firestore().batch()

        try await collection.getDocuments().documents.forEach {
            guard var dto = try? $0.data(as: ItemDTO.self) else {
                throw Errors.invalidDTO
            }

            dto.done = done

            let encodedData = try Firestore.Encoder().encode(dto)
            batch.updateData(
                encodedData,
                forDocument: collection.document($0.documentID)
            )
        }

        try await batch.commit()
    }

    /// Updates the sort order of items in a list
    public func sortItems(
        items: [ItemDTO],
        listId: String
    ) async throws {
        let batch = Firestore.firestore().batch()

        try items.enumerated().forEach { index, item in
            guard let id = item.id else {
                return
            }
            var mutableItem = item
            mutableItem.index = index

            let encodedData = try Firestore.Encoder().encode(mutableItem)
            batch.updateData(
                encodedData,
                forDocument: itemsCollection(listId: listId).document(id)
            )
        }

        try await batch.commit()
    }
}
