import Combine
import Foundation
import Data
import Application
import Entities

/// Protocol defining the business logic operations for managing list items
protocol ListItemsUseCaseApi {
    /// Fetches items for a specific list
    /// - Parameter listId: ID of the list to fetch items from
    /// - Returns: Publisher emitting array of items
    func fetchItems(
        listId: String
    ) -> AnyPublisher<[Item], Error>

    /// Adds a new item to a list
    /// - Parameters:
    ///   - name: Name of the item to add
    ///   - list: List to add the item to
    /// - Returns: Result containing the added item or error
    func addItem(
        with name: String,
        list: UserList
    ) async -> ActionResult<Item>

    /// Deletes an item from a list
    /// - Parameters:
    ///   - itemId: ID of the item to delete
    ///   - listId: ID of the list containing the item
    /// - Returns: Result indicating success or error
    func deleteItem(
        itemId: String,
        listId: String
    ) async -> ActionResult<EquatableVoid>

    /// Updates an item's name
    /// - Parameters:
    ///   - item: Item to update
    ///   - listId: ID of the list containing the item
    /// - Returns: Result containing the updated item or error
    func updateItemName(
        item: Item,
        listId: String
    ) async -> ActionResult<Item>

    /// Updates an item's completion status
    /// - Parameters:
    ///   - item: Item to update
    ///   - list: List containing the item
    /// - Returns: Result containing the updated item or error
    func updateItemDone(
        item: Item,
        list: UserList
    ) async -> ActionResult<Item>

    /// Sorts items in a list
    /// - Parameters:
    ///   - items: Items to sort
    ///   - listId: ID of the list containing the items
    /// - Returns: Result indicating success or error
    func sortItems(
        items: [Item],
        listId: String
    ) async -> ActionResult<EquatableVoid>
}

extension ListItems {
    /// Implementation of the ListItemsUseCaseApi protocol
    struct UseCase: ListItemsUseCaseApi {
        /// Possible errors that can occur during use case operations
        private enum Errors: Error, LocalizedError {
            case emptyItemName

            var errorDescription: String? {
                switch self {
                case .emptyItemName:
                    return "Item can't be empty."
                }
            }
        }

        private let itemsRepository: ItemsRepositoryApi
        private let listsRepository: ListsRepositoryApi

        init(
            itemsRepository: ItemsRepositoryApi = ItemsRepository(),
            listsRepository: ListsRepositoryApi = ListsRepository()
        ) {
            self.itemsRepository = itemsRepository
            self.listsRepository = listsRepository
        }

        func fetchItems(
            listId: String
        ) -> AnyPublisher<[Item], Error> {
            itemsRepository.fetchItems(listId: listId)
                .tryMap { items in
                    items.sorted { $0.index < $1.index }
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }

        func addItem(
            with name: String,
            list: UserList
        ) async -> ActionResult<Item> {
            guard !name.isEmpty else {
                return .failure(Errors.emptyItemName)
            }

            do {
                let item = try await itemsRepository.addItem(
                    with: name,
                    listId: list.documentId
                )

                _ = try await listsRepository.updateList(list)

                return .success(item)
            }
            catch {
                return .failure(error)
            }
        }

        func deleteItem(
            itemId: String,
            listId: String
        ) async -> ActionResult<EquatableVoid> {
            do {
                try await itemsRepository.deleteItem(
                    itemId: itemId,
                    listId: listId
                )
                return .success()
            }
            catch {
                return .failure(error)
            }
        }

        func updateItemName(
            item: Item,
            listId: String
        ) async -> ActionResult<Item> {
            do {
                let updatedItem = try await itemsRepository.updateItem(
                    item: item,
                    listId: listId
                )

                return .success(updatedItem)
            }
            catch {
                return .failure(error)
            }
        }

        func updateItemDone(
            item: Item,
            list: UserList
        ) async -> ActionResult<Item> {
            do {
                let updatedItem = try await itemsRepository.updateItem(
                    item: item,
                    listId: list.documentId
                )

                _ = try await listsRepository.updateList(list)

                return .success(updatedItem)
            }
            catch {
                return .failure(error)
            }
        }

        func sortItems(
            items: [Item],
            listId: String
        ) async -> ActionResult<EquatableVoid> {
            do {
                try await itemsRepository.sortItems(
                    items: items,
                    listId: listId
                )
                return .success()
            }
            catch {
                return .failure(error)
            }
        }
    }
}
