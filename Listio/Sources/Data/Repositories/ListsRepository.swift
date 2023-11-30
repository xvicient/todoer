protocol ListsRepositoryApi {
    func fetchLists(
        completion: @escaping (Result<[ListModel], Error>) -> Void
    )
    func addList(
        with name: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteList(
        _ documentId: String?
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
    
    func fetchLists(completion: @escaping (Result<[ListModel], Error>) -> Void) {
        listsDataSource.fetchLists(
            uuid: usersDataSource.uuid) { result in
                switch result {
                case .success(let dto):
                    completion(.success(
                        dto.map {
                            $0.toDomain
                        }
                    ))
                case .failure(let error):
                    completion(.failure(error))
                }
                
            }
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
}
