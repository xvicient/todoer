import Combine
import Foundation
import Entities

/// Protocol defining the API for managing todo items
public protocol ItemsRepositoryApi {
    /// Retrieves all items in a list
    /// - Parameter listId: ID of the list to fetch items from
    /// - Returns: A publisher that emits an array of items or an error
    func fetchItems(
        listId: String
    ) -> AnyPublisher<[Item], Error>

    /// Adds a new item to a list
    /// - Parameters:
    ///   - name: Name of the item
    ///   - listId: ID of the list to add the item to
    /// - Returns: The created item
    /// - Throws: Error if creation fails
    func addItem(
        with name: String,
        listId: String
    ) async throws -> Item

    /// Deletes an item from a list
    /// - Parameters:
    ///   - itemId: ID of the item to delete
    ///   - listId: ID of the list containing the item
    /// - Throws: Error if deletion fails
    func deleteItem(
        itemId: String,
        listId: String
    ) async throws

    /// Updates an existing item in a list
    /// - Parameters:
    ///   - item: Updated item data
    ///   - listId: ID of the list containing the item
    /// - Returns: The updated item
    /// - Throws: Error if update fails
    func updateItem(
        item: Item,
        listId: String
    ) async throws -> Item

    /// Toggles the completion status of all items in a list
    /// - Parameters:
    ///   - listId: ID of the list containing the items
    ///   - done: New completion status for all items
    /// - Throws: Error if update fails
    func toogleAllItems(
        listId: String,
        done: Bool
    ) async throws

    /// Updates the order of items in a list
    /// - Parameters:
    ///   - items: Array of items with updated indices
    ///   - listId: ID of the list containing the items
    /// - Throws: Error if sorting fails
    func sortItems(
        items: [Item],
        listId: String
    ) async throws
}

/// Implementation of ItemsRepositoryApi using Firebase Firestore
public final class ItemsRepository: ItemsRepositoryApi {
    /// Data source for managing items in Firestore
    private let itemsDataSource: ItemsDataSourceApi

    /// Creates a new items repository
    /// - Parameter itemsDataSource: Data source for managing items (defaults to ItemsDataSource)
    public init(
        itemsDataSource: ItemsDataSourceApi = ItemsDataSource()
    ) {
        self.itemsDataSource = itemsDataSource
    }

    /// Retrieves all items in a list
    /// - Parameter listId: ID of the list to fetch items from
    /// - Returns: A publisher that emits an array of items or an error
    public func fetchItems(
        listId: String
    ) -> AnyPublisher<[Item], Error> {
        itemsDataSource.fetchItems(listId: listId)
            .tryMap { items in
                items.map {
                    $0.toDomain
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    /// Adds a new item to a list
    /// - Parameters:
    ///   - name: Name of the item
    ///   - listId: ID of the list to add the item to
    /// - Returns: The created item
    /// - Throws: Error if creation fails
    public func addItem(
        with name: String,
        listId: String
    ) async throws -> Item {
        try await itemsDataSource.addItem(
            with: name,
            listId: listId
        ).toDomain
    }

    /// Deletes an item from a list
    /// - Parameters:
    ///   - itemId: ID of the item to delete
    ///   - listId: ID of the list containing the item
    /// - Throws: Error if deletion fails
    public func deleteItem(
        itemId: String,
        listId: String
    ) async throws {
        try await itemsDataSource.deleteItem(
            itemId: itemId,
            listId: listId
        )
    }

    /// Updates an existing item in a list
    /// - Parameters:
    ///   - item: Updated item data
    ///   - listId: ID of the list containing the item
    /// - Returns: The updated item
    /// - Throws: Error if update fails
    public func updateItem(
        item: Item,
        listId: String
    ) async throws -> Item {
        try await itemsDataSource.updateItem(
            item: item.toDTO,
            listId: listId
        ).toDomain
    }

    /// Toggles the completion status of all items in a list
    /// - Parameters:
    ///   - listId: ID of the list containing the items
    ///   - done: New completion status for all items
    /// - Throws: Error if update fails
    public func toogleAllItems(
        listId: String,
        done: Bool
    ) async throws {
        try await itemsDataSource.toogleAllItems(
            listId: listId,
            done: done
        )
    }

    /// Updates the order of items in a list
    /// - Parameters:
    ///   - items: Array of items with updated indices
    ///   - listId: ID of the list containing the items
    /// - Throws: Error if sorting fails
    public func sortItems(
        items: [Item],
        listId: String
    ) async throws {
        try await itemsDataSource.sortItems(
            items: items.map { $0.toDTO },
            listId: listId
        )
    }
}

/// Extension to convert ItemDTO to domain model
extension ItemDTO {
    /// Converts the DTO to a domain model
    fileprivate var toDomain: Item {
        Item(
            id: UUID(),
            documentId: id ?? "",
            name: name,
            done: done,
            index: index
        )
    }
}

/// Extension to convert Item to DTO
extension Item {
    /// Converts the domain model to a DTO
    var toDTO: ItemDTO {
        ItemDTO(
            id: documentId,
            name: name,
            done: done,
            index: index
        )
    }
}
