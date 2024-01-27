import FirebaseFirestore
import FirebaseFirestoreSwift

protocol UsersDataSourceApi {
    var uuid: String { get }
    
    func createUser(
        with uuid: String,
        email: String?,
        displayName: String?,
        photoUrl: String?,
        provider: String
    ) async throws
    
    func getUsers(
        with fields: [UsersDataSource.SearchField]
    ) async throws -> [UserDTO]

    func setUuid(
        _ value: String
    )
}

final class UsersDataSource: UsersDataSourceApi {
    
    struct SearchField {
        enum Key: String {
            case uuid
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
    
    @AppSetting(key: "uuid", defaultValue: "") var uuid: String
    private let usersCollection = Firestore.firestore().collection("users")
    
    func setUuid(_ value: String) {
        uuid = value
    }
    
    func createUser(
        with uuid: String,
        email: String?,
        displayName: String?,
        photoUrl: String?,
        provider: String
    ) async throws {
        let document = usersCollection.document()
        let documentId = document.documentID
        let dto = UserDTO(
            id: documentId,
            uuid: uuid,
            email: email,
            displayName: displayName,
            photoUrl: photoUrl,
            provider: provider
        )
        
        _ = try usersCollection.addDocument(from: dto)
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
}
