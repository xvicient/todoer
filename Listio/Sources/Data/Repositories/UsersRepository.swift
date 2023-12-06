protocol UsersRepositoryApi {
    func createUser(
        with uuid: String,
        email: String?,
        displayName: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func getSelfUser() async throws -> UserModel
    func getUser(
        _ email: String
    ) async throws -> UserDTO
}

final class UsersRepository: UsersRepositoryApi {
    
    let usersDataSource: UsersDataSourceApi
    
    init(usersDataSource: UsersDataSourceApi = UsersDataSource()) {
        self.usersDataSource = usersDataSource
    }
    
    func createUser(
        with uuid: String,
        email: String?,
        displayName: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        usersDataSource.createUser(with: uuid,
                                   email: email,
                                   displayName: displayName,
                                   completion: completion)
    }
    
    func getSelfUser() async throws -> UserModel {
        try await usersDataSource.getSelfUser().toDomain
    }
    
    func getUser(
        _ email: String
    ) async throws -> UserDTO {
        try await usersDataSource.getUser(email)
    }
}
