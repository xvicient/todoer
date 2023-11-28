protocol UsersRepositoryApi {
    func createUser(
        with uuid: String,
        email: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class UsersRepository: UsersRepositoryApi {
    
    let usersDataSource: UsersDataSourceApi
    
    init(usersDataSource: UsersDataSourceApi = UsersDataSource()) {
        self.usersDataSource = usersDataSource
    }
    
    func createUser(
        with uuid: String,
        email: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        usersDataSource.createUser(with: uuid, email: email, completion: completion)
    }
}
