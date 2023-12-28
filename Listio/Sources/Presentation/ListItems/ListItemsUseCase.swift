import Foundation
import Combine

protocol ListItemsUseCaseApi {
    func fetchItems(
        listId: String
    ) -> AnyPublisher<[Item], Error>
    func addItem(
        with name: String,
        listId: String
    ) async throws -> Result<Item, Error>
}

extension ListItems {
    struct UseCase: ListItemsUseCaseApi {
        private enum Errors: Error {
            case signInError
        }
        private let itemsRepository: ItemsRepositoryApi
        
        init(itemsRepository: ItemsRepositoryApi = ItemsRepository()) {
            self.itemsRepository = itemsRepository
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
        ) async throws -> Result<Item, Error> {
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
    }
}
