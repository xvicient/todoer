import Testing
import Entities

@testable import Data

struct ItemsRepositoryTests {
    
    private lazy var itemsRepository: ItemsRepositoryApi = {
        ItemsRepository(itemsDataSource: dataSourceMock)
    }()
    private var dataSourceMock = ItemsDataSourceMock()
    private var itemDTOMock = ItemMock.item.toDTO
    
    @Test
    mutating func example() async throws {
        givenASuccessAddItem()
        
        let item = try await itemsRepository.addItem(
            with: itemDTOMock.name,
            listId: "1"
        )
        
        #expect(item.name == itemDTOMock.name)
    }
}

private extension ItemsRepositoryTests {
    func givenASuccessAddItem() {
        dataSourceMock.addItemResult = .success(itemDTOMock)
    }
}
