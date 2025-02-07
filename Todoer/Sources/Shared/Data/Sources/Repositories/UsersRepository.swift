import Entities

/// Protocol defining the API for managing users
public protocol UsersRepositoryApi {
    /// Sets the current user's ID
    /// - Parameter value: User ID to set
    func setUid(_ value: String)

    /// Creates a new user record
    /// - Parameters:
    ///   - uid: User's unique identifier
    ///   - email: User's email address (optional)
    ///   - displayName: User's display name (optional)
    ///   - photoUrl: URL to user's profile photo (optional)
    ///   - provider: Authentication provider used (e.g., "google", "apple")
    /// - Throws: Error if user creation fails
    func createUser(
        with uid: String,
        email: String?,
        displayName: String?,
        photoUrl: String?,
        provider: String
    ) async throws

    /// Retrieves the current user's data
    /// - Returns: Current user data if found, nil otherwise
    /// - Throws: Error if retrieval fails
    func getSelfUser() async throws -> User?

    /// Retrieves a user by their unique identifier
    /// - Parameter uid: User's unique identifier
    /// - Returns: User data if found, nil otherwise
    /// - Throws: Error if retrieval fails
    func getUser(
        uid: String
    ) async throws -> User?

    /// Retrieves a user by their email address
    /// - Parameter email: User's email address
    /// - Returns: User data if found, nil otherwise
    /// - Throws: Error if retrieval fails
    func getUser(
        email: String
    ) async throws -> User?

    /// Retrieves a user by email that is not the specified user
    /// - Parameters:
    ///   - email: User's email address
    ///   - uid: User ID to exclude
    /// - Returns: User data if found, nil otherwise
    /// - Throws: Error if retrieval fails
    func getNotSelfUser(
        email: String,
        uid: String
    ) async throws -> User?

    /// Retrieves multiple users by their unique identifiers, excluding the current user
    /// - Parameter uids: Array of user IDs to retrieve
    /// - Returns: Array of user data
    /// - Throws: Error if retrieval fails
    func getNotSelfUsers(
        uids: [String]
    ) async throws -> [User]

    /// Deletes the current user's data
    /// - Throws: Error if deletion fails
    func deleteUser() async throws
}

/// Implementation of UsersRepositoryApi using Firebase Firestore
public final class UsersRepository: UsersRepositoryApi {

    /// Type alias for search field to improve code readability
    typealias SearchField = UsersDataSource.SearchField

    /// Data source for managing users in Firestore
    var usersDataSource: UsersDataSourceApi = UsersDataSource()

    /// Creates a new users repository
    public init() {}

    /// Sets the current user's ID
    /// - Parameter value: User ID to set
    public func setUid(_ value: String) {
        usersDataSource.uid = value
    }

    /// Creates a new user record
    /// - Parameters:
    ///   - uid: User's unique identifier
    ///   - email: User's email address (optional)
    ///   - displayName: User's display name (optional)
    ///   - photoUrl: URL to user's profile photo (optional)
    ///   - provider: Authentication provider used (e.g., "google", "apple")
    /// - Throws: Error if user creation fails
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

    /// Retrieves the current user's data
    /// - Returns: Current user data if found, nil otherwise
    /// - Throws: Error if retrieval fails
    public func getSelfUser() async throws -> User? {
        try await usersDataSource.getUsers(
            with: [SearchField(.uid, .equal(usersDataSource.uid))]
        )
        .first?
        .toDomain
    }

    /// Retrieves a user by their unique identifier
    /// - Parameter uid: User's unique identifier
    /// - Returns: User data if found, nil otherwise
    /// - Throws: Error if retrieval fails
    public func getUser(
        uid: String
    ) async throws -> User? {
        try await usersDataSource.getUsers(
            with: [SearchField(.uid, .equal(uid))]
        )
        .first?
        .toDomain
    }

    /// Retrieves a user by their email address
    /// - Parameter email: User's email address
    /// - Returns: User data if found, nil otherwise
    /// - Throws: Error if retrieval fails
    public func getUser(
        email: String
    ) async throws -> User? {
        try await usersDataSource.getUsers(
            with: [SearchField(.email, .equal(email))]
        )
        .first?
        .toDomain
    }

    /// Retrieves a user by email that is not the specified user
    /// - Parameters:
    ///   - email: User's email address
    ///   - uid: User ID to exclude
    /// - Returns: User data if found, nil otherwise
    /// - Throws: Error if retrieval fails
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
        .toDomain
    }

    /// Retrieves multiple users by their unique identifiers, excluding the current user
    /// - Parameter uids: Array of user IDs to retrieve
    /// - Returns: Array of user data
    /// - Throws: Error if retrieval fails
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
            .map { $0.toDomain }
        }
    }

    /// Deletes the current user's data
    /// - Throws: Error if deletion fails
    public func deleteUser() async throws {
        try await usersDataSource.deleteUser()
    }
}

/// Extension to convert UserDTO to domain model
extension UserDTO {
    /// Converts the DTO to a domain model
    fileprivate var toDomain: User {
        User(
            documentId: id ?? "",
            uid: uid,
            email: email,
            displayName: displayName,
            photoUrl: photoUrl,
            provider: provider
        )
    }
}

/// Extension to convert User to DTO
extension User {
    /// Converts the domain model to a DTO
    fileprivate var toDomain: UserDTO {
        UserDTO(
            uid: uid,
            email: email,
            displayName: displayName,
            photoUrl: photoUrl,
            provider: provider
        )
    }
}
