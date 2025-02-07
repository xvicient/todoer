import FirebaseFirestore
import Common

/// Protocol defining the API for interacting with user data
protocol UsersDataSourceApi {
    /// The current user's ID
    var uid: String { get set }

    /// Retrieves users matching specific search criteria
    /// - Parameter fields: Array of search fields to filter users
    /// - Returns: Array of user DTOs
    /// - Throws: Error if the retrieval fails
    func getUsers(
        with fields: [UsersDataSource.SearchField]
    ) async throws -> [UserDTO]

    /// Deletes the current user's data
    /// - Throws: Error if the deletion fails
    func deleteUser() async throws

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
}

/// Implementation of UsersDataSourceApi using Firebase Firestore
final class UsersDataSource: UsersDataSourceApi {
    
    /// Creates a new users data source
    public init() {}

    /// Structure defining search criteria for users
    struct SearchField {
        /// Keys that can be searched on
        enum Key: String {
            /// User's unique identifier
            case uid
            /// User's email address
            case email
        }
        
        /// Types of filters that can be applied
        enum Filter {
            /// Exact match filter
            case equal(String)
            /// Not equal filter
            case notEqual(String)
            /// In array filter
            case `in`([String])
        }
        
        /// The key to search on
        let key: Key
        /// The filter to apply
        let filter: Filter

        /// Creates a new search field
        /// - Parameters:
        ///   - key: The key to search on
        ///   - filter: The filter to apply
        init(_ key: Key, _ filter: Filter) {
            self.key = key
            self.filter = filter
        }
    }

    /// Errors that can occur when working with users
    private enum Errors: Error {
        /// User data not found
        case missingUser
        /// List of user IDs is empty
        case emptyUidList
    }

    /// App setting for storing the current user's ID
    @AppSetting(key: "uid", defaultValue: "") private var _uid: String
    /// Reference to the Firestore users collection
    private let usersCollection = Firestore.firestore().collection("users")

    /// The current user's ID
    var uid: String {
        get { _uid }
        set { _uid = newValue }
    }

    /// Retrieves users matching specific search criteria
    /// - Parameter fields: Array of search fields to filter users
    /// - Returns: Array of user DTOs
    /// - Throws: Error if the retrieval fails
    func getUsers(
        with fields: [SearchField]
    ) async throws -> [UserDTO] {
        var query: Query = usersCollection

        fields.forEach {
            switch $0.filter {
            case .equal(let value):
                query = query.whereField($0.key.rawValue, isEqualTo: value)
            case .notEqual(let value):
                query = query.whereField($0.key.rawValue, isNotEqualTo: value)
            case .in(let value):
                query = query.whereField($0.key.rawValue, in: value)
            }
        }

        return try await query.getDocuments()
            .documents
            .map { try $0.data(as: UserDTO.self) }
    }

    /// Deletes the current user's data
    /// - Throws: Error if the deletion fails
    func deleteUser() async throws {
        try await getUsers(with: [SearchField(.uid, .equal(uid))])
            .compactMap { $0.id }
            .forEach {
                usersCollection.document($0).delete()
            }
    }

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
    ) async throws {
        let document = usersCollection.document()
        let documentId = document.documentID
        let dto = UserDTO(
            id: documentId,
            uid: uid,
            email: email,
            displayName: displayName,
            photoUrl: photoUrl,
            provider: provider
        )

        try usersCollection.addDocument(from: dto)
    }
}
