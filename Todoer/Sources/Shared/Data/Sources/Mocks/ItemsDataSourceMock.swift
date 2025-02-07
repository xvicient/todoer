import Combine
import Entities
import FirebaseFirestore
import xRedux

@testable import Data

public class ItemsDataSourceMock: ItemsDataSourceApi {

    public var fetchItemsResult: [ItemDTO]!
    public var addItemResult: Result<ItemDTO, Error>!
    public var deleteItemResult: Result<Void, Error>!
    public var updateItemResult: Result<ItemDTO, Error>!
    public var toogleAllItemsResult: Result<Void, Error>!
    public var sortItemsResult: ActionResult<EquatableVoid>!

    public init() {}

    public enum DataSourceError: Error {
        case error
    }

    public func documents(listId: String) async throws -> [QueryDocumentSnapshot] {
        [QueryDocumentSnapshot]()
    }

    public func fetchItems(listId: String) -> AnyPublisher<[ItemDTO], any Error> {
        Just([
            ItemDTO(
                id: "",
                name: "",
                done: false,
                index: 1
            )
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }

    public func addItem(with name: String, listId: String) async throws -> ItemDTO {
        switch addItemResult {
        case .success(let item):
            return item
        case .failure(let error):
            throw error
        case .none:
            assertionFailure("Missing addItemResult mock")
            throw DataSourceError.error
        }
    }

    public func deleteItem(itemId: String, listId: String) async throws {
        switch deleteItemResult {
        case .success: break
        case .failure(let error):
            throw error
        case .none:
            assertionFailure("Missing deleteItemResult mock")
            throw DataSourceError.error
        }
    }

    public func updateItem(item: ItemDTO, listId: String) async throws -> ItemDTO {
        switch updateItemResult {
        case .success(let item):
            return item
        case .failure(let error):
            throw error
        case .none:
            assertionFailure("Missing updateItemResult mock")
            throw DataSourceError.error
        }
    }

    public func toogleAllItems(listId: String, done: Bool) async throws {
        switch toogleAllItemsResult {
        case .success: break
        case .failure(let error):
            throw error
        case .none:
            assertionFailure("Missing toogleAllItemsResult mock")
            throw DataSourceError.error
        }
    }

    public func sortItems(items: [ItemDTO], listId: String) async throws {
        switch sortItemsResult {
        case .success: break
        case .failure(let error):
            throw error
        case .none:
            assertionFailure("Missing sortItemsResult mock")
            throw DataSourceError.error
        }
    }

}
