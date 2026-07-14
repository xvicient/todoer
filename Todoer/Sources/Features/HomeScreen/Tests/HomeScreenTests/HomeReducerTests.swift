import CoordinatorContract
import CoordinatorMocks
import Entities
import EntitiesMocks
import Foundation
import HomeScreenContract
import ThemeComponents
import Testing
import xRedux
import xReduxTest

@testable import HomeScreen

@MainActor
class HomeReducerTests {

    private typealias HomeStore<R: Reducer> = TestStore<R.State, R.Action>
    private typealias UseCaseError = HomeUseCaseMock.UseCaseError

    private struct Dependencies: HomeScreenDependencies {
        let coordinator: CoordinatorApi?
    }

    private lazy var store: HomeStore<HomeReducer> = {
        TestStore(
            initialState: .init(),
            reducer: HomeReducer(
                dependencies: Dependencies(coordinator: coordinatorMock),
                useCase: useCaseMock
            )
        )
    }()
    private var useCaseMock = HomeUseCaseMock()
    private var coordinatorMock = CoordinatorMock()
    private var listsMock = [ListMock.list]

    @Test("Fetch home data success after view appears")
    func testOnViewAppearAndFetchHomeData_Success() async {
        givenASuccessHomeDataFetch()

        await store.send(.onViewAppear) {
            $0.shared.viewState == .loading(true)
        }

        await store.receive(.fetchDataResult(useCaseMock.fetchHomeDataResult)) { [listsMock] in
            $0.shared.viewState == .idle && $0.shared.items == listsMock
        }
    }

    @Test("Fetch home data fails after view appears")
    func testOnViewAppearAndFetchHomeData_Failure() async {
        givenAFailureHomeDataFetch()

        await store.send(.onViewAppear) {
            $0.shared.viewState == .loading(true)
        }

        await store.receive(.fetchDataResult(useCaseMock.fetchHomeDataResult)) {
            $0.shared.viewState == .error(UseCaseError.error.localizedDescription)
        }
    }

    @Test("Did move list successfully")
    func testDidMoveList_Success() async {
        givenASuccessHomeDataFetch()
        givenASuccessListsMove()

        await store.send(.onViewAppear) {
            $0.shared.viewState == .loading(true)
        }

        await store.receive(.fetchDataResult(useCaseMock.fetchHomeDataResult)) {
            $0.shared.viewState == .idle
        }

        await store.send(.shared(.didChangeEditMode(.active))) {
            $0.shared.viewState == .updating && $0.shared.editMode == .active
        }

        await store.send(.shared(.didMove(IndexSet(integer: 0), 0))) {
            $0.shared.viewState == .updating
        }

        await store.receive(.shared(.moveResult(.success()))) {
            $0.shared.viewState == .updating
        }
    }

    @Test("Did move list fails")
    func testDidMoveList_Failure() async {
        givenASuccessHomeDataFetch()
        givenAFailureListsMove()

        await store.send(.onViewAppear) {
            $0.shared.viewState == .loading(true)
        }

        await store.receive(.fetchDataResult(useCaseMock.fetchHomeDataResult)) {
            $0.shared.viewState == .idle
        }

        await store.send(.shared(.didChangeEditMode(.active))) {
            $0.shared.viewState == .updating && $0.shared.editMode == .active
        }

        await store.send(.shared(.didMove(IndexSet(integer: 0), 0))) {
            $0.shared.viewState == .updating
        }

        await store.receive(.shared(.moveResult(.failure(UseCaseError.error)))) {
            $0.shared.viewState == .error()
        }
    }
}

extension HomeReducerTests {
    fileprivate func givenASuccessHomeDataFetch() {
        useCaseMock.fetchHomeDataResult = .success(
            HomeData(lists: listsMock, invitations: [])
        )
    }

    fileprivate func givenAFailureHomeDataFetch() {
        useCaseMock.fetchHomeDataResult = .failure(UseCaseError.error)
    }

    fileprivate func givenASuccessListsMove() {
        useCaseMock.voidResult = .success()
    }

    fileprivate func givenAFailureListsMove() {
        useCaseMock.voidResult = .failure(UseCaseError.error)
    }
}
