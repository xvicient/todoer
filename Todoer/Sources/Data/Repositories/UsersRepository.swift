protocol UsersRepositoryApi {
    
    func setUuid(_ value: String)
    
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
    
    func getNotSelfUser(
        email: String,
        uid: String
    ) async throws -> User?
    
    func getNotSelfUsers(
        uids: [String]
    ) async throws -> [User]
}

final class UsersRepository: UsersRepositoryApi {
    
    typealias SearchField = UsersDataSource.SearchField
    
    var usersDataSource: UsersDataSourceApi
    
    init(usersDataSource: UsersDataSourceApi = UsersDataSource()) {
        self.usersDataSource = usersDataSource
    }
    
    func setUuid(_ value: String) {
        usersDataSource.setUuid(value)
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
            with: [SearchField(.uuid, .equal(usersDataSource.uuid))]
        )
        .first?
        .toDomain
    }
    
    func getUser(
        uid: String
    ) async throws -> User? {
        try await usersDataSource.getUsers(
            with: [SearchField(.uuid, .equal(uid))]
        )
        .first?
        .toDomain
    }
    
    func getUser(
        email: String
    ) async throws -> User? {
        try await usersDataSource.getUsers(
            with: [SearchField(.email, .equal(email))]
        )
        .first?
        .toDomain
    }
    
    func getNotSelfUser(
        email: String,
        uid: String
    ) async throws -> User? {
        try await usersDataSource.getUsers(
            with: [SearchField(.email, .equal(email)),
                   SearchField(.uuid, .notEqual(uid))]
        )
        .first?
        .toDomain
    }
    
    func getNotSelfUsers(
        uids: [String]
    ) async throws -> [User] {
        let notSelfUids = uids.filter { $0 != usersDataSource.uuid }
        
        if notSelfUids.isEmpty {
            return []
        } else {
            return try await usersDataSource.getUsers(
                with: [SearchField(.uuid, .in(notSelfUids))]
            )
            .map { $0.toDomain }
        }
    }
}
