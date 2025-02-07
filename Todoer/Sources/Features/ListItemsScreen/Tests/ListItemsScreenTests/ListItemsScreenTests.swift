import Testing
import xRedux
import xReduxTest
import Entities
import Combine
import CoordinatorMocks
import EntitiesMocks

@testable import ListItemsScreen

@MainActor
struct ListItemsScreenTests {
    
    private typealias ListItemsStore<R: Reducer> = TestStore<R.State, R.Action>
    private typealias UseCaseError = ListItemsUseCaseMock.UseCaseError
    
    private struct ReducerDependencies: ListItemsReducerDependencies {
        let list: UserList
        let useCase: ListItemsUseCaseApi
    }
    
    private lazy var store: ListItemsStore<ListItems.Reducer> = {
        TestStore(
            initialState: .init(),
            reducer: ListItems.Reducer(
                dependencies: ReducerDependencies(
                    list: listMock,
                    useCase: useCaseMock
                )
            )
        )
    }()
    private var useCaseMock = ListItemsUseCaseMock()
    private var coordinatorMock = CoordinatorMock()
    private var itemMock = ItemMock.item
    private var listMock = ListMock.list
    
    @Test("Fetch users success after view appears")
    mutating func testDidViewAppearAndFetchUsers_Success() async {
        givenASuccessItemsFetch()
        
        await store.send(.onAppear) {
            $0.viewState == .loading
        }
        
        await store.receive(.fetchItemsResult(useCaseMock.fetchItemsResult)) { [listMock, itemMock] in
            $0.viewState == .idle &&
            $0.viewModel.listName == listMock.name &&
            $0.viewModel.items == [itemMock].map { $0.toItemRow }
        }
    }
    
    @Test("Fetch users fails after view appears")
    mutating func testDidViewAppearAndFetchUsers_Failure() async {
        givenAFailureItemsFetch()
        
        await store.send(.onAppear) {
            $0.viewState == .loading
        }
        
        await store.receive(.fetchItemsResult(useCaseMock.fetchItemsResult)) {
            $0.viewState == .error(UseCaseError.error.localizedDescription) &&
            $0.viewModel.listName.isEmpty &&
            $0.viewModel.items.count == 0
        }
    }
    
    @Test("Add new item and submit it successfully")
    mutating func testDidTapAddRowButtonAndDidTapSubmitItemButton_Success() async {
        givenASuccessItemSubmit()
        
        await store.send(.didTapAddRowButton) {
            $0.viewState == .addingItem &&
            $0.viewModel.items.first?.isEditing == true
        }
        
        await store.send(.didTapSubmitItemButton(itemMock.name)) {
            $0.viewState == .addingItem
        }
        
        await store.receive(.addItemResult(useCaseMock.addItemResult)) {
            $0.viewState == .idle &&
            !$0.viewModel.items.contains { $0.isEditing }
        }
    }
    
    @Test("Add new item but submit fails")
    mutating func testDidTapAddRowButtonAndDidTapSubmitItemButton_Failure() async {
        givenAFailureItemSubmit()
        
        await store.send(.didTapAddRowButton) {
            $0.viewState == .addingItem &&
            $0.viewModel.items.first?.isEditing == true
        }
        
        await store.send(.didTapSubmitItemButton(itemMock.name)) {
            $0.viewState == .addingItem
        }
        
        await store.receive(.addItemResult(useCaseMock.addItemResult)) {
            $0.viewState == .error(UseCaseError.error.localizedDescription) &&
            $0.viewModel.items.first?.isEditing == true
        }
    }
    
    @Test("Add new item and cancel it successfully")
    mutating func testDidTapAddRowButtonAndDidTapCancelAddRowButton_Success() async {
        await store.send(.didTapAddRowButton) {
            $0.viewState == .addingItem &&
            $0.viewModel.items.first?.isEditing == true
        }
        
        await store.send(.didTapCancelAddItemButton) {
            $0.viewState == .idle &&
            !$0.viewModel.items.contains { $0.isEditing }
        }
    }
    
}

extension ListItemsScreenTests {
    fileprivate func givenASuccessItemsFetch() {
        useCaseMock.fetchItemsResult = .success(
            [itemMock]
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
