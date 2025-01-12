import XCTest
import Application
import ApplicationTests
import Data
import Entities
import Mocks

@testable import ShareListScreen

@MainActor
final class ShareReducerTests: XCTestCase {
	private typealias ShareStore<R: Reducer> = TestStore<R.State, R.Action>
	private typealias UseCaseError = ShareListUseCaseMock.UseCaseError

	struct Dependencies: ShareListDependencies {
		var useCase: ShareListUseCaseApi
		var list: UserList
	}

    private lazy var store: ShareStore<ShareList.Reducer> = {
        TestStore(
            initialState: .init(),
            reducer: ShareList.Reducer(
                coordinator: coordinator,
                dependencies: Dependencies(
                    useCase: useCaseMock,
                    list: ListMock.list
                )
            )
        )
    }()
	private var useCaseMock = ShareListUseCaseMock()
	private var coordinator = CoordinatorMock()

	func testDidViewAppearAndFetchUsers_Success() async {
		givenASuccessUsersFetch()

		await store.send(.onAppear) {
			$0.viewState == .idle
		}

		await store.receive(.fetchUsersResult(useCaseMock.fetchUsersResult)) {
			$0.viewState == .idle
		}
	}

	func testDidViewAppearAndFetchUsers_Failure() async {
		givenAFailureUsersFetch()

		await store.send(.onAppear) {
			$0.viewState == .idle
		}

		await store.receive(.fetchUsersResult(useCaseMock.fetchUsersResult)) {
			$0.viewState == .idle
		}
	}

	func testDidTapShareList_Success() async {
		givenASuccessShareList()

		await store.send(.didTapShareListButton("test@todoer.com")) {
			$0.viewState == .idle
		}

		await store.receive(.shareListResult(useCaseMock.shareListResult)) {
			$0.viewState == .idle
		}

		XCTAssert(coordinator.isDismissSheetCalled)
	}

	func testDidTapShareList_Failure() async {
		givenAFailureShareList()

		await store.send(.didTapShareListButton("test@todoer.com")) {
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
		useCaseMock.fetchUsersResult = .success(UserMock.users(1))
	}

	fileprivate func givenAFailureUsersFetch() {
		useCaseMock.fetchUsersResult = .failure(UseCaseError.error)
	}

	fileprivate func givenASuccessShareList() {
		useCaseMock.shareListResult = .success()
	}

	fileprivate func givenAFailureShareList() {
		useCaseMock.shareListResult = .failure(UseCaseError.error)
	}
}
