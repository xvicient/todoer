/// Unit tests for the ListItems screen functionality
@MainActor
struct ListItemsScreenTests {
    
    /// Dependencies required by the ListItems reducer
    private struct ReducerDependencies: ListItemsReducerDependencies {
        let list: UserList
        let useCase: ListItemsUseCaseApi
    }
    
    /// Test store instance with mock dependencies
    private lazy var store: ShareStore<ListItems.Reducer> = {
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
    /// Mock use case for testing
    private var useCaseMock = ListItemsUseCaseMock()
    /// Mock coordinator for testing navigation
    private var coordinatorMock = CoordinatorMock()
    /// Mock item for testing operations
    private var itemMock = ItemMock.item
    /// Mock list for testing operations
    private var listMock = ListMock.list
    
    /// Tests successful item fetch when view appears
    /// Verifies list name and items are properly set
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
    
    /// Tests failed item fetch when view appears
    /// Verifies error state and empty view model
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
    
    /// Tests successful addition of a new item
    /// Verifies item editing state transitions
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
    
    /// Tests failed addition of a new item
    /// Verifies error state and editing state
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
    
    /// Tests successful cancellation of adding a new item
    /// Verifies item editing state transitions
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

/// Test helper methods for configuring mock behavior
private extension ListItemsScreenTests {
    /// Configures mock for successful items fetch
    func givenASuccessItemsFetch() {
        useCaseMock.fetchItemsResult = .success(
            [itemMock]
        )
    }
    
    /// Configures mock for failed items fetch
    func givenAFailureItemsFetch() {
        useCaseMock.fetchItemsResult = .failure(UseCaseError.error)
    }
    
    /// Configures mock for successful item submission
    func givenASuccessItemSubmit() {
        useCaseMock.addItemResult = .success(
            itemMock
        )
    }
    
    /// Configures mock for failed item submission
    func givenAFailureItemSubmit() {
        useCaseMock.addItemResult = .failure(UseCaseError.error)
    }
}
