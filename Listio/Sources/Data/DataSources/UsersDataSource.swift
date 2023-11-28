import FirebaseFirestore
import FirebaseFirestoreSwift

protocol UsersDataSourceApi {
    var uuid: String { get }
    func createUser(
        with uuid: String,
        email: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class UsersDataSource: UsersDataSourceApi {
    @AppSetting(key: "uuid", defaultValue: "") var uuid: String
    private let usersCollection = Firestore.firestore().collection("users")
    
    func createUser(
        with uuid: String,
        email: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            let document = usersCollection.document()
            let documentId = document.documentID
            let dto = UserDTO(
                id: documentId,
                uuid: uuid,
                email: email
            )
            _ = try usersCollection.addDocument(from: dto)
            completion(.success(Void()))
            self.uuid = uuid
        } catch {
            completion(.failure(error))
        }
    }
}
