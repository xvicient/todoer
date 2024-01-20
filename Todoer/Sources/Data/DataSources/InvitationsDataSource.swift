import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

protocol InvitationsDataSourceApi {
    func fetchInvitations(
        uuid: String
    ) -> AnyPublisher<[InvitationDTO], Error>
    
    func sendInvitation(
        ownerName: String,
        ownerEmail: String,
        listId: String,
        listName: String,
        invitedId: String
    ) async throws
    
    func deleteInvitation(
        _ documentId: String
    ) async throws
}

final class InvitationsDataSource: InvitationsDataSourceApi {
    
    private var snapshotListener: ListenerRegistration?
    private var listenerSubject: PassthroughSubject<[InvitationDTO], Error>?
    
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
            .addSnapshotListener { query, error in
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
                                index: Date().milliseconds)
        _ = try invitationsCollection.addDocument(from: dto)
    }
    
    func deleteInvitation(
        _ documentId: String
    ) async throws {
        try await invitationsCollection.document(documentId).delete()
    }
}
