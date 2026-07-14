import Combine
import Entities
import xRedux
import Foundation

@testable import HomeScreen

class HomeUseCaseMock: HomeUseCaseApi {

    var sharedListsCount: Int = 0
    var fetchHomeDataResult: ActionResult<HomeData>!
    var addSharedListsResult: ActionResult<[UserList]>!
    var updateListResult: ActionResult<UserList>!
    var addListResult: ActionResult<UserList>!
    var voidResult: ActionResult<EquatableVoid>!

    enum UseCaseError: Error {
        case error
    }

    func addSharedLists() async -> ActionResult<[UserList]> {
        addSharedListsResult
    }

    func fetchHomeData() -> AnyPublisher<HomeData, any Error> {
        switch fetchHomeDataResult {
        case .success(let data):
            return Just(data)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure:
            return Fail<HomeData, Error>(
                error: UseCaseError.error
            )
            .eraseToAnyPublisher()
        case .none:
            assertionFailure("Missing fetchHomeDataResult mock")
            return Empty<HomeData, Error>(completeImmediately: false)
                .eraseToAnyPublisher()
        }
    }

    func add(
        name: String
    ) async -> ActionResult<UserList> {
        addListResult
    }

    @discardableResult
    func update(
        _ element: UserList
    ) async -> ActionResult<UserList> {
        updateListResult
    }

    func toggle(
        _ element: UserList,
        in elements: [UserList]
    ) async -> ActionResult<EquatableVoid> {
        voidResult
    }

    func delete(
        _ element: UserList
    ) async -> ActionResult<EquatableVoid> {
        voidResult
    }

    func sort(
        _ elements: [UserList]
    ) async -> ActionResult<EquatableVoid> {
        voidResult
    }
}
