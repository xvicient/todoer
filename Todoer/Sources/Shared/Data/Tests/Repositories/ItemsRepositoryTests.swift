/// Unit tests for the ItemsRepository implementation
struct ItemsRepositoryTests {
    
    /// Repository instance under test
    private lazy var itemsRepository: ItemsRepositoryApi = {
        ItemsRepository(itemsDataSource: dataSourceMock)
    }()
    /// Mock data source for testing
    private var dataSourceMock = ItemsDataSourceMock()
    /// Mock item for testing
    private var itemMock = ItemMock.item
    /// Mock item DTO for testing
    private var itemDTOMock = ItemMock.item.toDTO
    
    /// Tests successful item addition
    /// Verifies that the added item has the expected name
    @Test("Test add item success")
    mutating func testAddItemSuccess() async throws {
        givenASuccessAddItem()
        
        let item = try await itemsRepository.addItem(
            with: itemDTOMock.name,
            listId: "1"
        )
        
        #expect(item.name == itemDTOMock.name)
    }
    
    /// Tests failed item addition
    /// Verifies that the appropriate error is thrown
    @Test("Test add item failure")
    mutating func testAddItemFailure() async throws {
        givenAFailureAddItem()
        
        await #expect(throws: DataSourceError.self) {
            try await itemsRepository.addItem(
                with: itemDTOMock.name,
                listId: "1"
            )
        }
    }
    
    /// Tests successful item update
    /// Verifies that the updated item has the expected name
    @Test("Test update item success")
    mutating func testUpdateItemSuccess() async throws {
        givenASuccessUpdateItem()
        
        let item = try await itemsRepository.updateItem(
            item: itemMock,
            listId: "1"
        )
        
        #expect(item.name == itemDTOMock.name)
    }
    
    /// Tests failed item update
    /// Verifies that the appropriate error is thrown
    @Test("Test update item failure")
    mutating func testUpdateItemFailure() async throws {
        givenAFailureUpdateItem()
        
        await #expect(throws: DataSourceError.self) {
            try await itemsRepository.updateItem(
                item: itemMock,
                listId: "1"
            )
        }
    }
}

/// Test helper methods for configuring mock behavior
private extension ItemsRepositoryTests {
    /// Configures mock for successful item addition
    func givenASuccessAddItem() {
        dataSourceMock.addItemResult = .success(itemDTOMock)
    }
    
    /// Configures mock for failed item addition
    func givenAFailureAddItem() {
        dataSourceMock.addItemResult = .failure(DataSourceError.error)
    }
    
    /// Configures mock for successful item update
    func givenASuccessUpdateItem() {
        dataSourceMock.updateItemResult = .success(itemDTOMock)
    }
    
    /// Configures mock for failed item update
    func givenAFailureUpdateItem() {
        dataSourceMock.updateItemResult = .failure(DataSourceError.error)
    }
    
    /// Configures mock for successful item sorting
    func givenASuccessSortItems() {
        dataSourceMock.sortItemsResult = .success()
    }
}
