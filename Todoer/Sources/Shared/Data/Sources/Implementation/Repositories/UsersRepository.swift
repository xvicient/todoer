import Entities

public protocol UsersRepositoryApi {
    func setUid(_ value: String)

    func createUser(
        with uid: String,
        email: String?,
        displayName: String?,
        photoUrl: String?,
        provider: String
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

    func deleteUser() async throws
}

public final class UsersRepository: UsersRepositoryApi {

    typealias SearchField = UsersDataSource.SearchField

    var usersDataSource: UsersDataSourceApi = UsersDataSource()

    public init() {}

    public func setUid(_ value: String) {
        usersDataSource.uid = value
    }

    public func createUser(
        with uid: String,
        email: String?,
        displayName: String?,
        photoUrl: String?,
        provider: String
    ) async throws {
        try await usersDataSource.createUser(
            with: uid,
            email: email,
            displayName: displayName,
            photoUrl: photoUrl,
            provider: provider
        )
    }

    public func getSelfUser() async throws -> User? {
        try await usersDataSource.getUsers(
            with: [SearchField(.uid, .equal(usersDataSource.uid))]
        )
        .first?
        .toDomain()
    }

    public func getUser(
        uid: String
    ) async throws -> User? {
        try await usersDataSource.getUsers(
            with: [SearchField(.uid, .equal(uid))]
        )
        .first?
        .toDomain()
    }

    public func getUser(
        email: String
    ) async throws -> User? {
        try await usersDataSource.getUsers(
            with: [SearchField(.email, .equal(email))]
        )
        .first?
        .toDomain()
    }

    public func getNotSelfUser(
        email: String,
        uid: String
    ) async throws -> User? {
        try await usersDataSource.getUsers(
            with: [
                SearchField(.email, .equal(email)),
                SearchField(.uid, .notEqual(uid)),
            ]
        )
        .first?
        .toDomain()
    }

    public func getNotSelfUsers(
        uids: [String]
    ) async throws -> [User] {
        let notSelfUids = uids.filter { $0 != usersDataSource.uid }

        if notSelfUids.isEmpty {
            return []
        }
        else {
            return try await usersDataSource.getUsers(
                with: [SearchField(.uid, .in(notSelfUids))]
            )
            .compactMap { try? $0.toDomain() }
        }
    }

    public func deleteUser() async throws {
        try await usersDataSource.deleteUser()
    }
}

extension UserDTO {
    fileprivate func toDomain() throws -> User {
        try User(
            id: id,
            uid: uid,
            email: email,
            displayName: displayName,
            photoUrl: photoUrl,
            provider: provider
        )
    }
}

extension User {
    fileprivate var toDomain: UserDTO {
        UserDTO(
            id: id,
            uid: uid,
            email: email,
            displayName: displayName,
            photoUrl: photoUrl,
            provider: provider
        )
    }
}
