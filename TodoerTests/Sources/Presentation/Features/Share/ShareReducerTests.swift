import XCTest
@testable import Todoer

@MainActor
final class ShareReducerTests: XCTestCase {
    private typealias ShareStore<R: Reducer> = TestStore<R.State, R.Action>
    
    struct Dependencies: ShareListDependencies {
        var useCase: ShareListUseCaseApi
        var list: List
    }
    
    private var store: ShareStore<ShareList.Reducer>!
    private var useCaseMock = ShareListUseCaseMock()
    private var useCaseError = ShareListUseCaseMock.UseCaseError.error
    
    override func setUp() {
        super.setUp()
        setupStore()
    }
    
    private func setupStore() {
        store = TestStore(
            initialState: .init(),
            reducer: ShareList.Reducer(
                coordinator: Coordinator(),
                dependencies: Dependencies(
                    useCase: useCaseMock,
                    list: ListMock.list
                )
            )
        )
    }
    
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
    }
    
    func testDidTapShareList_Failure() async {
        givenAFailureShareList()
        
        await store.send(.didTapShareListButton("test@todoer.com")) {
            $0.viewState == .idle
        }
        
        await store.receive(.shareListResult(useCaseMock.shareListResult)) {
            $0.viewState == .error(useCaseError.localizedDescription)
        }
        
        await store.send(.didTapDismissError) {
            $0.viewState == .idle
        }
    }
}

private extension ShareReducerTests {
    func givenASuccessUsersFetch() {
        useCaseMock.fetchUsersResult = .success(UserMock.users(1))
    }
    
    func givenAFailureUsersFetch() {
        useCaseMock.fetchUsersResult = .failure(useCaseError)
    }
    func givenASuccessShareList() {
        useCaseMock.shareListResult = .success()
    }
    
    func givenAFailureShareList() {
        useCaseMock.shareListResult = .failure(useCaseError)
    }
}
