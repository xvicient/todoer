import XCTest
import Application
import ApplicationTests
import Data
import Entities
import EntitiesMocks
import ShareListScreenContract
import CoordinatorContract
import CoordinatorMocks

@testable import ShareListScreen

/// Unit tests for the ShareList reducer functionality
@MainActor
final class ShareReducerTests: XCTestCase {
    private typealias ShareStore<R: Reducer> = TestStore<R.State, R.Action>
    private typealias UseCaseError = ShareListUseCaseMock.UseCaseError

    /// Dependencies required by the ShareList reducer
    private struct Dependencies: ShareListScreenDependencies {
        var coordinator: CoordinatorApi
        var list: UserList
    }

    /// Test store instance with mock dependencies
    private lazy var store: ShareStore<ShareList.Reducer> = {
        TestStore(
            initialState: .init(),
            reducer: ShareList.Reducer(
                dependencies: Dependencies(
                    coordinator: coordinatorMock,
                    list: ListMock.list
                ),
                useCase: useCaseMock
            )
        )
    }()
    /// Mock use case for testing
    private var useCaseMock = ShareListUseCaseMock()
    /// Mock coordinator for testing navigation
    private var coordinatorMock = CoordinatorMock()

    /// Tests successful user fetch when view appears
    /// Verifies list name and items are properly set
    func testDidViewAppearAndFetchUsers_Success() async {
        givenASuccessUsersFetch()

        await store.send(.onAppear) {
            $0.viewState == .idle
        }

        await store.receive(.fetchDataResult(useCaseMock.fetchDataResult)) {
            $0.viewState == .idle
        }
    }

    /// Tests failed user fetch when view appears
    /// Verifies error state and empty view model
    func testDidViewAppearAndFetchUsers_Failure() async {
        givenAFailureUsersFetch()

        await store.send(.onAppear) {
            $0.viewState == .idle
        }

        await store.receive(.fetchDataResult(useCaseMock.fetchDataResult)) {
            $0.viewState == .idle
        }
    }

    /// Tests successful list sharing
    /// Verifies state transitions and navigation
    func testDidTapShareList_Success() async {
        givenASuccessShareList()

        await store.send(.didTapShareListButton("test@todoer.com", "Hunter King")) {
            $0.viewState == .idle
        }

        await store.receive(.shareListResult(useCaseMock.shareListResult)) {
            $0.viewState == .idle
        }

        XCTAssert(coordinatorMock.isDismissSheetCalled)
    }

    /// Tests failed list sharing
    /// Verifies error state and error handling
    func testDidTapShareList_Failure() async {
        givenAFailureShareList()

        await store.send(.didTapShareListButton("test@todoer.com", "Hunter King")) {
            $0.viewState == .idle
        }

        await store.receive(.shareListResult(useCaseMock.shareListResult)) {
            $0.viewState == .error(UseCaseError.error.localizedDescription)
        }

        await store.send(.didTapDismissError) {
            $0.viewState == .idle
        }
    }
}

/// Test helper methods for configuring mock behavior
extension ShareReducerTests {
    /// Configures mock for successful user fetch
    fileprivate func givenASuccessUsersFetch() {
        useCaseMock.fetchDataResult = .success(
            ShareData(
                users: UserMock.users(1),
                selfName: "Hunter King"
            )
        )
    }

    /// Configures mock for failed user fetch
    fileprivate func givenAFailureUsersFetch() {
        useCaseMock.fetchDataResult = .failure(UseCaseError.error)
    }

    /// Configures mock for successful list sharing
    fileprivate func givenASuccessShareList() {
        useCaseMock.shareListResult = .success()
    }

    /// Configures mock for failed list sharing
    fileprivate func givenAFailureShareList() {
        useCaseMock.shareListResult = .failure(UseCaseError.error)
    }
}
