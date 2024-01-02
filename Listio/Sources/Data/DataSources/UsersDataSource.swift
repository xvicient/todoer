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
    
    func getSelfUser() async throws -> UserDTO
    
    func getUser(
        _ email: String
    ) async throws -> UserDTO
    
    func setUuid(_ value: String)
    
    func fetchUsers(
        uids: [String]
    ) async throws -> [UserDTO]
}

final class UsersDataSource: UsersDataSourceApi {
    
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
    
    func getSelfUser() async throws -> UserDTO {
        try await withCheckedThrowingContinuation { continuation in
            usersCollection
                .whereField("uuid", isEqualTo: uuid)
                .getDocuments { [weak self] query, error in
                    self?.getUserDocument(continuation)(query, error)
                }
        }
    }
    
    func getUser(
        _ email: String
    ) async throws -> UserDTO {
        try await withCheckedThrowingContinuation { continuation in
            usersCollection
                .whereField("email", isEqualTo: email)
                .getDocuments { [weak self] query, error in
                    self?.getUserDocument(continuation)(query, error)
                }
        }
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
    
    private func getUserDocument(
        _ continuation: CheckedContinuation<UserDTO, Error>
    ) -> ((QuerySnapshot?, Error?) -> Void) {
        { query, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            
            if let user = query?.documents
                .compactMap({ try? $0.data(as: UserDTO.self) }).first {
                continuation.resume(returning: user)
            } else {
                continuation.resume(throwing: Errors.missingUser)
            }
        }
    }
}
