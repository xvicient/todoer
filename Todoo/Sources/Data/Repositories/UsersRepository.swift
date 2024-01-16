protocol UsersRepositoryApi {
    func createUser(
        with uuid: String,
        email: String?,
        displayName: String?,
        photoUrl: String?
    ) async throws
    
    func getSelfUser() async throws -> User
    
    func getUser(
        _ email: String
    ) async throws -> UserDTO
    
    func setUuid(_ value: String)
    
    func fetchUsers(
        uids: [String]
    ) async throws -> [User]
}

final class UsersRepository: UsersRepositoryApi {
    
    var usersDataSource: UsersDataSourceApi
    
    init(usersDataSource: UsersDataSourceApi = UsersDataSource()) {
        self.usersDataSource = usersDataSource
    }
    
    func createUser(
        with uuid: String,
        email: String?,
        displayName: String?,
        photoUrl: String?
    ) async throws {
        try await usersDataSource.createUser(with: uuid,
                                             email: email,
                                             displayName: displayName,
                                             photoUrl: photoUrl)
    }
    
    func getSelfUser() async throws -> User {
        try await usersDataSource.getSelfUser().toDomain
    }
    
    func getUser(
        _ email: String
    ) async throws -> UserDTO {
        try await usersDataSource.getUser(email)
    }
    
    func setUuid(_ value: String) {
        usersDataSource.setUuid(value)
    }
    
    func fetchUsers(
        uids: [String]
    ) async throws -> [User] {
        try await usersDataSource.fetchUsers(uids: uids)
            .map { $0.toDomain }

    }
}
