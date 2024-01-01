import Foundation
import Combine

protocol ListItemsUseCaseApi {
    func fetchItems(
        listId: String
    ) -> AnyPublisher<[Item], Error>
    
    func addItem(
        with name: String,
        listId: String
    ) async -> Result<Item, Error>
    
    func deleteItem(
        itemId: String?,
        listId: String
    ) async -> Result<Void, Error>
    
    func updateItem(
        item: any ListRow,
        list: List
    ) async -> Result<Item, Error>
}

extension ListItems {
    struct UseCase: ListItemsUseCaseApi {
        private enum Errors: Error {
            case emptyItemName
            case unexpectedError
        }
        
        private let itemsRepository: ItemsRepositoryApi
        private let listsRepository: ListsRepositoryApi
        
        init(itemsRepository: ItemsRepositoryApi = ItemsRepository(),
             listsRepository: ListsRepositoryApi = ListsRepository()) {
            self.itemsRepository = itemsRepository
            self.listsRepository = listsRepository
        }
        
        func fetchItems(
            listId: String
        ) -> AnyPublisher<[Item], Error> {
            itemsRepository.fetchItems(listId: listId)
                .tryMap { items in
                    items.sorted { $0.dateCreated < $1.dateCreated }
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        func addItem(
            with name: String,
            listId: String
        ) async -> Result<Item, Error> {
            guard !name.isEmpty else {
                return .failure(Errors.emptyItemName)
            }
            
            do {
                let item = try await itemsRepository.addItem(
                    with: name,
                    listId: listId
                )
                return .success(item)
            } catch {
                return .failure(error)
            }
        }
        
        func deleteItem(
            itemId: String?,
            listId: String
        ) async -> Result<Void, Error> {
            guard let itemId = itemId else {
                return .failure(Errors.unexpectedError)
            }
            
            do {
                try await itemsRepository.deleteItem(
                    itemId: itemId,
                    listId: listId
                )
                return .success(())
            } catch {
                return .failure(error)
            }
        }
        
        func updateItem(
            item: any ListRow,
            list: List
        ) async -> Result<Item, Error> {
            guard var item = item as? Item else {
                return .failure(Errors.unexpectedError)
            }
            
            do {
                let result = try await itemsRepository.updateItem(
                    item: item,
                    listId: list.documentId
                )
                
                _ = try await listsRepository.updateList(list)
                
                return .success(result)
            } catch {
                return .failure(error)
            }
        }
    }
}
