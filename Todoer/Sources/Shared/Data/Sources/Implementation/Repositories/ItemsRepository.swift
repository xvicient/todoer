import Combine
import Entities
import Foundation

public protocol ItemsRepositoryApi {
    func fetchItems(
        listId: String
    ) -> AnyPublisher<[Item], Error>

    func addItem(
        with name: String,
        listId: String
    ) async throws -> Item

    func deleteItem(
        itemId: String,
        listId: String
    ) async throws

    func updateItem(
        item: Item,
        listId: String
    ) async throws -> Item

    func toogleAllItems(
        listId: String,
        done: Bool
    ) async throws

    func sortItems(
        items: [Item],
        listId: String
    ) async throws
}

public final class ItemsRepository: ItemsRepositoryApi {
    private let itemsDataSource: ItemsDataSourceApi

    public init(
        itemsDataSource: ItemsDataSourceApi = ItemsDataSource()
    ) {
        self.itemsDataSource = itemsDataSource
    }

    public func fetchItems(
        listId: String
    ) -> AnyPublisher<[Item], Error> {
        itemsDataSource.fetchItems(listId: listId)
            .scanUpdates() // Scan for updates in next events to update the previous ones
            .map { $0.compactMap { try? $0.toDomain() } }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func addItem(
        with name: String,
        listId: String
    ) async throws -> Item {
        try await itemsDataSource.addItem(
            with: name,
            listId: listId
        ).toDomain()
    }

    public func deleteItem(
        itemId: String,
        listId: String
    ) async throws {
        try await itemsDataSource.deleteItem(
            itemId: itemId,
            listId: listId
        )
    }

    public func updateItem(
        item: Item,
        listId: String
    ) async throws -> Item {
        try await itemsDataSource.updateItem(
            item: item.toDTO,
            listId: listId
        ).toDomain()
    }

    public func toogleAllItems(
        listId: String,
        done: Bool
    ) async throws {
        try await itemsDataSource.toogleAllItems(
            listId: listId,
            done: done
        )
    }

    public func sortItems(
        items: [Item],
        listId: String
    ) async throws {
        try await itemsDataSource.sortItems(
            items: items.map(\.toDTO),
            listId: listId
        )
    }
}

extension ItemDTO {
    fileprivate func toDomain() throws -> Item {
        try Item(
            id: id,
            name: name,
            done: done,
            index: index
        )
    }
}

extension Item {
    fileprivate var toDTO: ItemDTO {
        ItemDTO(
            id: id,
            name: name,
            done: done,
            index: index
        )
    }
}
