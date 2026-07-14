import Combine
import Entities
import xRedux
import Foundation

@testable import ListItemsScreen

class ListItemsUseCaseMock: ListItemsUseCaseApi {

    var fetchItemsResult: ActionResult<[Item]>!
    var addItemResult: ActionResult<Item>!
    var updateItemNameResult: ActionResult<Item>!
    var voidResult: ActionResult<EquatableVoid>!

    enum UseCaseError: Error {
        case error
    }

    func fetchItems() -> AnyPublisher<[Item], any Error> {
        switch fetchItemsResult {
        case .success(let items):
            return Just(items)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure:
            return Fail<[Item], Error>(
                error: UseCaseError.error
            )
            .eraseToAnyPublisher()
        case .none:
            assertionFailure("Missing fetchItemsResult mock")
            return Empty<[Item], Error>(completeImmediately: false)
                .eraseToAnyPublisher()
        }
    }

    func add(
        name: String
    ) async -> ActionResult<Item> {
        addItemResult
    }

    func update(
        _ element: Item
    ) async -> ActionResult<Item> {
        updateItemNameResult
    }

    func toggle(
        _ element: Item,
        in elements: [Item]
    ) async -> ActionResult<EquatableVoid> {
        voidResult
    }

    func delete(
        _ element: Item
    ) async -> ActionResult<EquatableVoid> {
        voidResult
    }

    func sort(
        _ elements: [Item]
    ) async -> ActionResult<EquatableVoid> {
        voidResult
    }

}
