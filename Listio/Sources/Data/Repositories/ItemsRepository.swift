import UIKit

protocol ItemsRepositoryApi {
    func fetchItems(
        listId: String,
        completion: @escaping (Result<[Item], Error>) -> Void
    )
    func addItem(
        with name: String,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteItem(
        _ documentId: String?,
        listId: String
    )
    func toggleItem(
        _ item: Item,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func toogleAllItemsBatch(
        listId: String?,
        done: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class ItemsRepository: ItemsRepositoryApi {
    private let producstDataSource: ItemsDataSourceApi
    
    init(producstDataSource: ItemsDataSourceApi = ItemsDataSource()) {
        self.producstDataSource = producstDataSource
    }
    
    func fetchItems(
        listId: String,
        completion: @escaping (Result<[Item], Error>) -> Void
    ) {
        producstDataSource.fetchItems(listId: listId) { result in
            switch result {
            case .success(let dto):
                completion(.success(
                    dto.map {
                        $0.toDomain
                    }
                ))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addItem(
        with name: String,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        producstDataSource.addItem(with: name,
                                      listId: listId,
                                      completion: completion)
    }
    
    func deleteItem(
        _ documentId: String?,
        listId: String
    ) {
        producstDataSource.deleteItem(documentId,
                                         listId: listId)
    }
    
    func toggleItem(
        _ item: Item,
        listId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        producstDataSource.toggleItem(item.toDTO,
                                         listId: listId,
                                         completion: completion)
    }
    
    func toogleAllItemsBatch(
        listId: String?,
        done: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        producstDataSource.toogleAllItemsBatch(listId: listId,
                                                  done: done,
                                                  completion: completion)
    }
}
