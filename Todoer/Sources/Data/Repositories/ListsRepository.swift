import Combine
import Foundation

protocol ListsRepositoryApi {
    func fetchLists(
    ) -> AnyPublisher<[List], Error>
    
    func addList(
        with name: String
    ) async throws -> List
    
    func deleteList(
        _ documentId: String
    ) async throws
    
    func toggleList(
        _ list: List
    ) async throws
    
    func importList(
        id: String
    ) async throws
    
    func updateList(
        _ list: List
    ) async throws -> List
    
    func sortLists(
        lists: [List]
    ) async throws
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
        with name: String
    ) async throws -> List {
        try await listsDataSource.addList(
            with: name,
            uuid: usersDataSource.uuid).toDomain
    }
    
    func deleteList(
        _ documentId: String
    ) async throws {
        try await listsDataSource.deleteList(documentId)
    }
    
    func toggleList(
        _ list: List
    ) async throws {
        try await listsDataSource.toggleList(list.toDTO)
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
    
    func sortLists(
        lists: [List]
    ) async throws {
        try await listsDataSource.sortLists(
            lists: lists.map { $0.toDTO }
        )
    }
}

private extension ListDTO {
    var toDomain: List {
        List(documentId: id ?? "",
             name: name,
             done: done,
             uuid: uuid,
             index: index)
    }
}

private extension List {
    var toDTO: ListDTO {
        ListDTO(id: documentId,
                name: name,
                done: done,
                uuid: uuid,
                index: index)
    }
}
