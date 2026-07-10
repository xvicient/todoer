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

    @discardableResult
    func updateList(
        list: UserList
    ) async -> ActionResult<UserList> {
        updateListResult
    }

    func toggleList(
        list: UserList
    ) async -> ActionResult<EquatableVoid> {
        voidResult
    }

    func deleteList(
        _ listId: String
    ) async -> ActionResult<EquatableVoid> {
        voidResult
    }

    func addList(
        name: String
    ) async -> ActionResult<UserList> {
        addListResult
    }

    func sortLists(
        lists: [UserList]
    ) async -> ActionResult<EquatableVoid> {
        voidResult
    }
}
