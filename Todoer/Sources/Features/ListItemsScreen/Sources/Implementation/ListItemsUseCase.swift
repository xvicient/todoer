import Combine
import Data
import Entities
import Foundation
import ThemeComponents
import xRedux

/// List-items' single use case. Conforms directly to the shared `TDListUseCaseApi` (add / update /
/// toggle / delete / sort) consumed by `TDListReducer`, and adds the item-specific `fetchItems`.
/// It carries the parent `list` so item operations can update it (e.g. marking the list done when
/// every item is completed). No adapter needed.
protocol ListItemsUseCaseApi: TDListUseCaseApi where Element == Item {
    func fetchItems() -> AnyPublisher<[Item], Error>
}

struct ListItemsUseCase: ListItemsUseCaseApi {
    private enum UseCaseErrors: Error, LocalizedError {
        case emptyItemName

        var errorDescription: String? {
            switch self {
            case .emptyItemName:
                return "Item name can't be empty."
            }
        }
    }

    private let list: UserList
    private let itemsRepository: ItemsRepositoryApi
    private let listsRepository: ListsRepositoryApi

    init(
        list: UserList,
        itemsRepository: ItemsRepositoryApi = ItemsRepository(),
        listsRepository: ListsRepositoryApi = ListsRepository()
    ) {
        self.list = list
        self.itemsRepository = itemsRepository
        self.listsRepository = listsRepository
    }

    func fetchItems() -> AnyPublisher<[Item], Error> {
        itemsRepository.fetchItems(listId: list.id)
            .tryMap { items in
                items.sorted { $0.index < $1.index }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func add(
        name: String
    ) async -> ActionResult<Item> {
        guard !name.isEmpty else {
            return .failure(UseCaseErrors.emptyItemName)
        }

        var parent = list
        parent.done = false

        do {
            let item = try await itemsRepository.addItem(
                with: name,
                listId: parent.id
            )

            _ = try await listsRepository.updateList(parent)

            return .success(item)
        }
        catch {
            return .failure(error)
        }
    }

    func update(
        _ element: Item
    ) async -> ActionResult<Item> {
        do {
            let updatedItem = try await itemsRepository.updateItem(
                item: element,
                listId: list.id
            )

            return .success(updatedItem)
        }
        catch {
            return .failure(error)
        }
    }

    /// Marks the parent list done when every item is completed.
    func toggle(
        _ element: Item,
        in elements: [Item]
    ) async -> ActionResult<EquatableVoid> {
        var parent = list
        parent.done = elements.allSatisfy { $0.done }

        do {
            _ = try await itemsRepository.updateItem(
                item: element,
                listId: parent.id
            )

            _ = try await listsRepository.updateList(parent)

            return .success()
        }
        catch {
            return .failure(error)
        }
    }

    func delete(
        _ element: Item
    ) async -> ActionResult<EquatableVoid> {
        do {
            try await itemsRepository.deleteItem(
                itemId: element.id,
                listId: list.id
            )
            return .success()
        }
        catch {
            return .failure(error)
        }
    }

    func sort(
        _ elements: [Item]
    ) async -> ActionResult<EquatableVoid> {
        do {
            try await itemsRepository.sortItems(
                items: elements,
                listId: list.id
            )
            return .success()
        }
        catch {
            return .failure(error)
        }
    }
}
