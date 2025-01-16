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

@MainActor
final class ShareReducerTests: XCTestCase {
	private typealias ShareStore<R: Reducer> = TestStore<R.State, R.Action>
	private typealias UseCaseError = ShareListUseCaseMock.UseCaseError

    private struct Dependencies: ShareListScreenDependencies {
        var coordinator: CoordinatorApi
		var list: UserList
	}

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
	private var useCaseMock = ShareListUseCaseMock()
	private var coordinatorMock = CoordinatorMock()

	func testDidViewAppearAndFetchUsers_Success() async {
		givenASuccessUsersFetch()

		await store.send(.onAppear) {
			$0.viewState == .idle
		}

		await store.receive(.fetchDataResult(useCaseMock.fetchDataResult)) {
			$0.viewState == .idle
		}
	}

	func testDidViewAppearAndFetchUsers_Failure() async {
		givenAFailureUsersFetch()

		await store.send(.onAppear) {
			$0.viewState == .idle
		}

		await store.receive(.fetchDataResult(useCaseMock.fetchDataResult)) {
			$0.viewState == .idle
		}
	}

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

extension ShareReducerTests {
	fileprivate func givenASuccessUsersFetch() {
        useCaseMock.fetchDataResult = .success(
            ShareData(
                users: UserMock.users(1),
                selfName: "Hunter King"
            )
        )
	}

	fileprivate func givenAFailureUsersFetch() {
		useCaseMock.fetchDataResult = .failure(UseCaseError.error)
	}

	fileprivate func givenASuccessShareList() {
		useCaseMock.shareListResult = .success()
	}

	fileprivate func givenAFailureShareList() {
		useCaseMock.shareListResult = .failure(UseCaseError.error)
	}
}
