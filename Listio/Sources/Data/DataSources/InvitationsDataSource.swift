import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

protocol InvitationsDataSourceApi {
    func fetchInvitations(
        uuid: String
    ) -> AnyPublisher<[InvitationDTO], Error>
    func fetchInvitations(
        uuid: String,
        completion: @escaping (Result<[InvitationDTO], Error>) -> Void
    )
    
    func sendInvitation(
        ownerName: String,
        ownerEmail: String,
        listId: String,
        listName: String,
        invitedId: String
    ) async throws
    
    func deleteInvitation(
        _ documentId: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class InvitationsDataSource: InvitationsDataSourceApi {
    
    private var snapshotListener: ListenerRegistration?
    private var listenerSubject: PassthroughSubject<[InvitationDTO], Error>?
    private var ignoreChanges = false
    
    private let invitationsCollection = Firestore.firestore().collection("invitations")
    
    deinit {
        snapshotListener?.remove()
        listenerSubject = nil
    }
    
    func fetchInvitations(
        uuid: String
    ) -> AnyPublisher<[InvitationDTO], Error> {
        let subject = PassthroughSubject<[InvitationDTO], Error>()
        listenerSubject = subject
        
        invitationsCollection
            .whereField("invitedId", isEqualTo: uuid)
            .addSnapshotListener { [weak self] query, error in
                guard let self = self else { return }
                
                guard !ignoreChanges else {
                    ignoreChanges = false
                    return
                }
                
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                let invitations = query?.documents
                    .compactMap { try? $0.data(as: InvitationDTO.self) }
                ?? []
                
                subject.send(invitations)
            }
        
        return subject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func fetchInvitations(
        uuid: String,
        completion: @escaping (Result<[InvitationDTO], Error>) -> Void
    ) {
        invitationsCollection
            .whereField("invitedId", isEqualTo: uuid)
            .addSnapshotListener { query, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let invitations = query?.documents
                    .compactMap { try? $0.data(as: InvitationDTO.self) }
                ?? []
                completion(.success(invitations))
            }
    }
    
    func sendInvitation(
        ownerName: String,
        ownerEmail: String,
        listId: String,
        listName: String,
        invitedId: String
    ) async throws {
        let dto = InvitationDTO(ownerName: ownerName,
                                ownerEmail: ownerEmail,
                                listId: listId,
                                listName: listName,
                                invitedId: invitedId,
                                dateCreated: Date().milliseconds)
        _ = try invitationsCollection.addDocument(from: dto)
    }
    
    func deleteInvitation(
        _ documentId: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let id = documentId else { return }
        invitationsCollection.document(id).delete() { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(Void()))
        }
    }
}
