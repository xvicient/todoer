protocol UsersRepositoryApi {
    func createUser(
        with uuid: String,
        email: String?,
        displayName: String?
    ) async throws
    func getSelfUser() async throws -> User
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
        displayName: String?
    ) async throws {
        try await usersDataSource.createUser(with: uuid,
                                             email: email,
                                             displayName: displayName)
    }
    
    func getSelfUser() async throws -> User {
        try await usersDataSource.getSelfUser().toDomain
    }
    
    func getUser(
        _ email: String
    ) async throws -> UserDTO {
        try await usersDataSource.getUser(email)
    }
}
