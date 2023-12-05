import FirebaseFirestore
import FirebaseFirestoreSwift

enum UsersDataSourceError: Error {
    case missingUser
}

protocol UsersDataSourceApi {
    var uuid: String { get }
    func createUser(
        with uuid: String,
        email: String?,
        displayName: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func getSelfUser() async throws -> UserDTO
    func getUser(
        _ uuid: String
    ) async throws -> UserDTO
}

final class UsersDataSource: UsersDataSourceApi {
    @AppSetting(key: "uuid", defaultValue: "") var uuid: String
    private let usersCollection = Firestore.firestore().collection("users")
    
    func createUser(
        with uuid: String,
        email: String?,
        displayName: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            let document = usersCollection.document()
            let documentId = document.documentID
            let dto = UserDTO(
                id: documentId,
                uuid: uuid,
                email: email,
                displayName: displayName
            )
            _ = try usersCollection.addDocument(from: dto)
            completion(.success(Void()))
            self.uuid = uuid
        } catch {
            completion(.failure(error))
        }
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
                continuation.resume(throwing: UsersDataSourceError.missingUser)
            }
        }
    }
}
