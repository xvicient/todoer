import Combine
import Common
import FirebaseFirestore

public protocol ItemsDataSourceApi {
    func documents(
        listId: String
    ) async throws -> [QueryDocumentSnapshot]

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
    ) async throws -> ItemDTO

    func toogleAllItems(
        listId: String,
        done: Bool
    ) async throws

    func sortItems(
        items: [ItemDTO],
        listId: String
    ) async throws
}

public final class ItemsDataSource: ItemsDataSourceApi {
    private enum Errors: Error {
        case invalidDTO
        case encodingError
    }

    public init() {}

    private func itemsCollection(
        listId: String
    ) -> CollectionReference {
        Firestore.firestore().collection("lists").document(listId).collection("items")
    }

    public func documents(
        listId: String
    ) async throws -> [QueryDocumentSnapshot] {
        try await itemsCollection(listId: listId).getDocuments().documents
    }

    public func fetchItems(
        listId: String
    ) -> AnyPublisher<[ItemDTO], Error> {
        itemsCollection(listId: listId)
            .snapshotPublisher()
            .filter { !$0.metadata.hasPendingWrites }
            .map { snapshot in
                snapshot.documents.compactMap { document -> ItemDTO? in
                    guard var dto = try? document.data(as: ItemDTO.self) else { return nil }
                    dto.id = document.documentID
                    return dto
                }
            }
            .eraseToAnyPublisher()
    }

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
            let docRef = try itemsCollection(listId: listId).addDocument(from: dto)
            let document = try await docRef.getDocument()
            guard var result = try? document.data(as: ItemDTO.self) else {
                throw Errors.invalidDTO
            }
            result.id = document.documentID
            return result
        }
        catch {
            throw (error)
        }
    }

    public func deleteItem(
        itemId: String,
        listId: String
    ) async throws {
        let itemDocument = itemsCollection(listId: listId).document(itemId)

        let _ = try await Firestore.firestore().runTransaction {
            (transaction, errorPointer) -> Any? in
            transaction.deleteDocument(itemDocument)
            return nil
        }
    }

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
            
            dto.id = $0.documentID
            dto.done = done

            let encodedData = try Firestore.Encoder().encode(dto)
            batch.updateData(
                encodedData,
                forDocument: collection.document($0.documentID)
            )
        }

        try await batch.commit()
    }

    public func sortItems(
        items: [ItemDTO],
        listId: String
    ) async throws {

        let batch = Firestore.firestore().batch()

        try items.forEach {
            guard let id = $0.id else {
                return
            }

            let encodedData = try Firestore.Encoder().encode($0)
            batch.updateData(
                encodedData,
                forDocument: itemsCollection(listId: listId).document(id)
            )
        }

        try await batch.commit()
    }
}
