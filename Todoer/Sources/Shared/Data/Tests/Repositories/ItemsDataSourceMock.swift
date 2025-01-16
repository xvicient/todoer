import Entities
import Combine

@testable import Data

public class ItemsDataSourceMock: ItemsDataSourceApi {
    public var fetchItemsResult: [ItemDTO]!
    public var addItemResult: Result<ItemDTO, Error>!
    public var deleteItemResult: Void!
    public var updateItemResult: ItemDTO!
    public var toogleAllItemsResult: Void!
    public var sortItemsResult: Void!
    
    public init() {}
    
    enum DataSourceError: Error {
        case error
    }
    
    public func fetchItems(listId: String) -> AnyPublisher<[ItemDTO], any Error> {
        Just([ItemDTO(id: "", name: "", done: false, index: 1)])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func addItem(with name: String, listId: String) async throws -> ItemDTO {
        switch addItemResult {
        case .success(let item):
            guard item.name == name else {
                throw DataSourceError.error
            }
            return item
        case .failure(let error):
            throw error
        case .none:
            assertionFailure("Missing addItemResult mock")
            throw DataSourceError.error
        }
    }
    
    public func deleteItem(itemId: String, listId: String) async throws {
        deleteItemResult
    }
    
    public func updateItem(item: ItemDTO, listId: String) async throws -> ItemDTO {
        guard let item = updateItemResult, item == item else {
            throw DataSourceError.error
        }
        return item
    }
    
    public func toogleAllItems(listId: String?, done: Bool) async throws {
        toogleAllItemsResult
    }
    
    public func sortItems(items: [ItemDTO], listId: String) async throws {
        sortItemsResult
    }
    
    
}
