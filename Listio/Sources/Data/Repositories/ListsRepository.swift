protocol ListsRepositoryApi {
    func fetchLists(
        completion: @escaping (Result<[ListDTO], Error>) -> Void
    )
    func addList(
        with name: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteList(
        _ list: ListDTO
    )
}

final class ListsRepository: ListsRepositoryApi {
    let listsDataSource: ListsDataSourceApi
    let usersDataSource: UsersDataSourceApi
    
    init(listsDataSource: ListsDataSourceApi = ListsDataSource(),
         usersDataSource: UsersDataSourceApi = UsersDataSource()) {
        self.listsDataSource = listsDataSource
        self.usersDataSource = usersDataSource
    }
    
    func fetchLists(completion: @escaping (Result<[ListDTO], Error>) -> Void) {
        listsDataSource.fetchLists(
            uuid: usersDataSource.uuid,
            completion: completion
        )
    }
    
    func addList(
        with name: String,
        completion: @escaping (Result<Void, Error>) -> Void) {
            listsDataSource.addList(
                with: name,
                uuid: usersDataSource.uuid,
                completion: completion)
        }
    
    func deleteList(_ list: ListDTO) {
        listsDataSource.deleteList(list)
    }
}
