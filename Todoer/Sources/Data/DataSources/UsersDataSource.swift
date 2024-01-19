import FirebaseFirestore
import FirebaseFirestoreSwift

protocol UsersDataSourceApi {
    var uuid: String { get }
    
    func createUser(
        with uuid: String,
        email: String?,
        displayName: String?,
        photoUrl: String?
    ) async throws
    
    func getUsers(
        with fields: [UsersDataSource.SearchField]
    ) async throws -> UserDTO?

    func setUuid(
        _ value: String
    )
    
    func fetchUsers(
        uids: [String]
    ) async throws -> [UserDTO]
}

final class UsersDataSource: UsersDataSourceApi {
    
    struct SearchField {
        enum Key: String {
            case uid
            case email
        }
        enum Filter {
            case equal
            case notEqual
        }
        let key: Key
        let filter: Filter
        let value: String
        
        init(_ key: Key, _ filter: Filter, _ value: String) {
            self.key = key
            self.filter = filter
            self.value = value
        }
    }
    
    enum Errors: Error {
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
        photoUrl: String?
    ) async throws {
        let document = usersCollection.document()
        let documentId = document.documentID
        let dto = UserDTO(
            id: documentId,
            uuid: uuid,
            email: email,
            displayName: displayName,
            photoUrl: photoUrl
        )
        
        _ = try usersCollection.addDocument(from: dto)
    }
    
    func getUsers(
        with fields: [SearchField]
    ) async throws -> UserDTO? {
        var query: Query = usersCollection
        
        fields.forEach {
            switch $0.filter {
            case .equal:
                query = query.whereField($0.key.rawValue, isEqualTo: $0.value)
            case .notEqual:
                query = query.whereField($0.key.rawValue, isNotEqualTo: $0.value)
            }
        }
        
        return try await query.getDocuments()
            .documents
            .map { try $0.data(as: UserDTO.self) }
            .first
    }
    
    func fetchUsers(
        uids: [String]
    ) async throws -> [UserDTO] {
        var mutableUids = uids
        mutableUids.removeAll { $0 == uuid }
        
        if mutableUids.isEmpty {
            throw Errors.emptyUidList
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                usersCollection
                    .whereField("uuid", in: mutableUids)
                    .getDocuments { query, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        let users = query?.documents
                            .compactMap { try? $0.data(as: UserDTO.self) }
                        ?? []
                        continuation.resume(returning: users)
                    }
            }
        }
    }
}
