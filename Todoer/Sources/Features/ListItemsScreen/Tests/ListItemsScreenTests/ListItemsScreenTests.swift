import Testing
import Application
import ApplicationTests
import Entities
import Mocks
import Combine

@testable import ListItemsScreen

@MainActor
struct ListItemsScreenTests {
    
    private typealias ShareStore<R: Reducer> = TestStore<R.State, R.Action>
    private typealias UseCaseError = ListItemsUseCaseMock.UseCaseError
    
    private struct ReducerDependencies: ListItemsReducerDependencies {
        let list: UserList
        let useCase: ListItemsUseCaseApi
    }
    
    private lazy var store: ShareStore<ListItems.Reducer> = {
        TestStore(
            initialState: .init(),
            reducer: ListItems.Reducer(
                dependencies: ReducerDependencies(
                    list: ListMock.list,
                    useCase: useCaseMock
                )
            )
        )
    }()
    private var useCaseMock = ListItemsUseCaseMock()
    private var coordinatorMock = CoordinatorMock()
    private var itemMock = ItemMock.item
    
    @Test("Fetch users success after view appears")
    mutating func testDidViewAppearAndFetchUsers_Success() async {
        givenASuccessItemsFetch()
        
        await store.send(.onAppear) {
            $0.viewState == .loading
        }
        
        await store.receive(.fetchItemsResult(useCaseMock.fetchItemsResult)) {
            $0.viewState == .idle
        }
    }
    
    @Test("Fetch users fails after view appears")
    mutating func testDidViewAppearAndFetchUsers_Failure() async {
        givenAFailureItemsFetch()
        
        await store.send(.onAppear) {
            $0.viewState == .loading
        }
        
        await store.receive(.fetchItemsResult(useCaseMock.fetchItemsResult)) {
            $0.viewState == .error(UseCaseError.error.localizedDescription)
        }
    }
    
    @Test("Add new item and submit it successfully")
    mutating func testDidTapAddRowButtonAndDidTapSubmitItemButton_Success() async {
        givenASuccessItemSubmit()
        
        await store.send(.didTapAddRowButton) {
            $0.viewState == .addingItem
        }
        
        await store.send(.didTapSubmitItemButton(itemMock.name)) {
            $0.viewState == .addingItem
        }
        
        await store.receive(.addItemResult(useCaseMock.addItemResult)) {
            $0.viewState == .idle
        }
    }
    
    @Test("Add new item but submit fails")
    mutating func testDidTapAddRowButtonAndDidTapSubmitItemButton_Failure() async {
        givenAFailureItemSubmit()
        
        await store.send(.didTapAddRowButton) {
            $0.viewState == .addingItem
        }
        
        await store.send(.didTapSubmitItemButton(itemMock.name)) {
            $0.viewState == .addingItem
        }
        
        await store.receive(.addItemResult(useCaseMock.addItemResult)) {
            $0.viewState == .error(UseCaseError.error.localizedDescription)
        }
    }
    
}

extension ListItemsScreenTests {
    fileprivate func givenASuccessItemsFetch() {
        useCaseMock.fetchItemsResult = .success(
            ItemMock.items(1)
        )
    }
    
    fileprivate func givenAFailureItemsFetch() {
        useCaseMock.fetchItemsResult = .failure(UseCaseError.error)
    }
    
    fileprivate func givenASuccessItemSubmit() {
        useCaseMock.addItemResult = .success(
            itemMock
        )
    }
    
    fileprivate func givenAFailureItemSubmit() {
        useCaseMock.addItemResult = .failure(UseCaseError.error)
    }
}
