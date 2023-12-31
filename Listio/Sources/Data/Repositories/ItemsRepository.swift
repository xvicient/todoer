import Foundation
import Combine

protocol ItemsRepositoryApi {
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
    )  async throws -> Item
    
    func toogleAllItemsBatch(
        listId: String?,
        done: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class ItemsRepository: ItemsRepositoryApi {
    private let itemsDataSource: ItemsDataSourceApi
    
    init(producstDataSource: ItemsDataSourceApi = ItemsDataSource()) {
        self.itemsDataSource = producstDataSource
    }
    
    func fetchItems(
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
    
    func addItem(
        with name: String,
        listId: String
    ) async throws -> Item {
        try await itemsDataSource.addItem(
            with: name,
            listId: listId
        ).toDomain
    }
    
    func deleteItem(
        itemId: String,
        listId: String
    ) async throws {
        try await itemsDataSource.deleteItem(itemId: itemId,
                                             listId: listId)
    }
    
    func updateItem(
        item: Item,
        listId: String
    )  async throws -> Item {
        try await itemsDataSource.updateItem(item: item.toDTO,
                                             listId: listId).toDomain
    }
    
    func toogleAllItemsBatch(
        listId: String?,
        done: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        itemsDataSource.toogleAllItemsBatch(listId: listId,
                                                  done: done,
                                                  completion: completion)
    }
}
