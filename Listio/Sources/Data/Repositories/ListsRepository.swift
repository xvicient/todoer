import Combine
import Foundation

protocol ListsRepositoryApi {
    func fetchLists(
    ) -> AnyPublisher<[List], Error>
    
    func addList(
        with name: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    func deleteList(
        _ documentId: String?
    )  
    
    func toggleList(
        _ list: List,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    func importList(
        id: String
    ) async throws
    
    func updateList(
        _ list: List
    ) async throws -> List
}

final class ListsRepository: ListsRepositoryApi {
    let listsDataSource: ListsDataSourceApi
    let usersDataSource: UsersDataSourceApi
    let itemsDataSource: ItemsDataSourceApi
    
    init(listsDataSource: ListsDataSourceApi = ListsDataSource(),
         usersDataSource: UsersDataSourceApi = UsersDataSource(),
         itemsDataSource: ItemsDataSourceApi = ItemsDataSource()) {
        self.listsDataSource = listsDataSource
        self.usersDataSource = usersDataSource
        self.itemsDataSource = itemsDataSource
    }
    
    func fetchLists(
    ) -> AnyPublisher<[List], Error> {
        listsDataSource.fetchLists(uuid: usersDataSource.uuid)
            .tryMap { lists in
                lists.map {
                    $0.toDomain
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func addList(
        with name: String,
        completion: @escaping (Result<Void, Error>) -> Void) {
            listsDataSource.addList(
                with: name,
                uuid: usersDataSource.uuid,
                completion: completion)
        }
    
    func deleteList(
        _ documentId: String?
    ) {
        listsDataSource.deleteList(documentId)
    }
    
    func toggleList(
        _ list: List,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        listsDataSource.toggleList(list.toDTO, completion: completion)
    }
    
    func importList(
        id: String
    ) async throws {
        try await listsDataSource.importList(id: id, uuid: usersDataSource.uuid)
    }
    
    func updateList(
        _ list: List
    ) async throws -> List {
        try await listsDataSource.updateList(list.toDTO).toDomain
    }
}
