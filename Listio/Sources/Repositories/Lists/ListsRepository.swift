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

struct ListsRepository: ListsRepositoryApi {
    let listsDataSource: ListsDataSource
    
    init(listsDataSource: ListsDataSource = ListsDataSource()) {
        self.listsDataSource = listsDataSource
    }
    
    func fetchLists(completion: @escaping (Result<[ListDTO], Error>) -> Void) {
        listsDataSource.fetchLists(completion: completion)
    }
    
    func addList(
        with name: String,
        completion: @escaping (Result<Void, Error>) -> Void) {
            listsDataSource.addList(with: name, completion: completion)
        }
    
    func deleteList(_ list: ListDTO) {
        listsDataSource.deleteList(list)
    }
}
