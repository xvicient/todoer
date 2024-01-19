protocol UsersRepositoryApi {
    func createUser(
        with uuid: String,
        email: String?,
        displayName: String?,
        photoUrl: String?
    ) async throws
    
    func getSelfUser() async throws -> User?
    
    func getUser(
        uid: String
    ) async throws -> User?
    
    func getUser(
        email: String
    ) async throws -> User?
    
    func getNoSelfUser(
        email: String
    ) async throws -> User?
    
    func setUuid(_ value: String)
    
    func fetchUsers(
        uids: [String]
    ) async throws -> [User]
}

final class UsersRepository: UsersRepositoryApi {
    
    typealias SearchField = UsersDataSource.SearchField
    
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
    
    func getSelfUser(
    ) async throws -> User? {
        try await usersDataSource.getUsers(
            with: [SearchField(.uid, .equal, usersDataSource.uuid)]
        )?.toDomain
    }
    
    func getUser(
        uid: String
    ) async throws -> User? {
        try await usersDataSource.getUsers(
            with: [SearchField(.uid, .equal, uid)]
        )?.toDomain
    }
    
    func getUser(
        email: String
    ) async throws -> User? {
        try await usersDataSource.getUsers(
            with: [SearchField(.email, .equal, email)]
        )?.toDomain
    }
    
    func getNoSelfUser(
        email: String
    ) async throws -> User? {
        try await usersDataSource.getUsers(
            with: [SearchField(.email, .equal, email),
                   SearchField(.uid, .notEqual, usersDataSource.uuid)]
        )?.toDomain
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
