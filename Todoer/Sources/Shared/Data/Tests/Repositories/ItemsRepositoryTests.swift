import DataMocks
import Entities
import EntitiesMocks
import Testing
import xRedux

@testable import Data

struct ItemsRepositoryTests {

    private typealias DataSourceError = ItemsDataSourceMock.DataSourceError

    private lazy var itemsRepository: ItemsRepositoryApi = {
        ItemsRepository(itemsDataSource: dataSourceMock)
    }()
    private var dataSourceMock = ItemsDataSourceMock()
    private var itemMock = ItemMock.item
    private var itemDTOMock = ItemMock.item.toDTO

    @Test("Test add item success")
    mutating func testAddItemSuccess() async throws {
        givenASuccessAddItem()

        let item = try await itemsRepository.addItem(
            with: itemDTOMock.name,
            listId: "1"
        )

        #expect(item.name == itemDTOMock.name)
    }

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

    @Test("Test update item success")
    mutating func testUpdateItemSuccess() async throws {
        givenASuccessUpdateItem()

        let item = try await itemsRepository.updateItem(
            item: itemMock,
            listId: "1"
        )

        #expect(item.name == itemDTOMock.name)
    }

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

extension ItemsRepositoryTests {
    fileprivate func givenASuccessAddItem() {
        dataSourceMock.addItemResult = .success(itemDTOMock)
    }

    fileprivate func givenAFailureAddItem() {
        dataSourceMock.addItemResult = .failure(DataSourceError.error)
    }

    fileprivate func givenASuccessUpdateItem() {
        dataSourceMock.updateItemResult = .success(itemDTOMock)
    }

    fileprivate func givenAFailureUpdateItem() {
        dataSourceMock.updateItemResult = .failure(DataSourceError.error)
    }

    fileprivate func givenASuccessSortItems() {
        dataSourceMock.sortItemsResult = .success()
    }
}
