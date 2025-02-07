import Common
import FirebaseFirestore

protocol UsersDataSourceApi {
    var uid: String { get set }

    func getUsers(
        with fields: [UsersDataSource.SearchField]
    ) async throws -> [UserDTO]

    func deleteUser() async throws

    func createUser(
        with uid: String,
        email: String?,
        displayName: String?,
        photoUrl: String?,
        provider: String
    ) async throws
}

final class UsersDataSource: UsersDataSourceApi {

    public init() {}

    struct SearchField {
        enum Key: String {
            case uid
            case email
        }
        enum Filter {
            case equal(String)
            case notEqual(String)
            case `in`([String])
        }
        let key: Key
        let filter: Filter

        init(_ key: Key, _ filter: Filter) {
            self.key = key
            self.filter = filter
        }
    }

    private enum Errors: Error {
        case missingUser
        case emptyUidList
    }

    @AppSetting(key: "uid", defaultValue: "") private var _uid: String
    private let usersCollection = Firestore.firestore().collection("users")

    var uid: String {
        get { _uid }
        set { _uid = newValue }
    }

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

    func deleteUser() async throws {
        try await getUsers(with: [SearchField(.uid, .equal(uid))])
            .compactMap { $0.id }
            .forEach {
                usersCollection.document($0).delete()
            }
    }

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
