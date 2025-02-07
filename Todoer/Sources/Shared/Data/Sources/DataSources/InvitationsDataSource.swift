import Combine
import FirebaseFirestore
import Common

/// Protocol defining the API for interacting with invitations data
protocol InvitationsDataSourceApi {
    /// Retrieves invitations matching the specified search criteria as a publisher
    /// - Parameter fields: Array of search fields to filter invitations
    /// - Returns: A publisher that emits arrays of invitation DTOs and can error
    func getInvitations(
        with fields: [InvitationsDataSource.SearchField]
    ) -> AnyPublisher<[InvitationDTO], Error>

    /// Retrieves invitations matching the specified search criteria
    /// - Parameter fields: Array of search fields to filter invitations
    /// - Returns: Array of invitation DTOs
    /// - Throws: Error if the retrieval fails
    func getInvitations(
        with fields: [InvitationsDataSource.SearchField]
    ) async throws -> [InvitationDTO]

    /// Creates and sends a new invitation
    /// - Parameters:
    ///   - ownerName: Name of the user sending the invitation
    ///   - ownerEmail: Email of the user sending the invitation
    ///   - listId: ID of the list being shared
    ///   - listName: Name of the list being shared
    ///   - invitedId: ID of the user being invited
    /// - Throws: Error if sending the invitation fails
    func sendInvitation(
        ownerName: String,
        ownerEmail: String,
        listId: String,
        listName: String,
        invitedId: String
    ) async throws

    /// Deletes an invitation
    /// - Parameter documentId: ID of the invitation document to delete
    /// - Throws: Error if the deletion fails
    func deleteInvitation(
        _ documentId: String
    ) async throws
}

/// Implementation of InvitationsDataSourceApi using Firebase Firestore
final class InvitationsDataSource: InvitationsDataSourceApi {

    /// Structure defining search criteria for invitations
    struct SearchField {
        /// Keys that can be searched on
        enum Key: String {
            /// ID of the invited user
            case invitedId
            /// ID of the shared list
            case listId
        }
        
        /// Types of filters that can be applied
        enum Filter {
            /// Exact match filter
            case equal(String)
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

    /// Registration for the Firestore snapshot listener
    private var snapshotListener: ListenerRegistration?
    /// Subject for publishing invitation updates
    private var listenerSubject: PassthroughSubject<[InvitationDTO], Error>?
    /// Reference to the Firestore invitations collection
    private let invitationsCollection = Firestore.firestore().collection("invitations")

    /// Removes the snapshot listener when the data source is deallocated
    deinit {
        snapshotListener?.remove()
        listenerSubject = nil
    }

    /// Retrieves invitations matching the specified search criteria as a publisher
    /// - Parameter fields: Array of search fields to filter invitations
    /// - Returns: A publisher that emits arrays of invitation DTOs and can error
    func getInvitations(
        with fields: [SearchField]
    ) -> AnyPublisher<[InvitationDTO], Error> {
        let subject = PassthroughSubject<[InvitationDTO], Error>()
        listenerSubject = subject

        invitationsQuery(with: fields)
            .addSnapshotListener { query, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }

                let invitations =
                    query?.documents
                    .compactMap { try? $0.data(as: InvitationDTO.self) }
                    ?? []

                subject.send(invitations)
            }

        return
            subject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Retrieves invitations matching the specified search criteria
    /// - Parameter fields: Array of search fields to filter invitations
    /// - Returns: Array of invitation DTOs
    /// - Throws: Error if the retrieval fails
    func getInvitations(
        with fields: [SearchField]
    ) async throws -> [InvitationDTO] {
        try await invitationsQuery(with: fields)
            .getDocuments()
            .documents
            .map { try $0.data(as: InvitationDTO.self) }
    }

    /// Creates and sends a new invitation
    /// - Parameters:
    ///   - ownerName: Name of the user sending the invitation
    ///   - ownerEmail: Email of the user sending the invitation
    ///   - listId: ID of the list being shared
    ///   - listName: Name of the list being shared
    ///   - invitedId: ID of the user being invited
    /// - Throws: Error if sending the invitation fails
    func sendInvitation(
        ownerName: String,
        ownerEmail: String,
        listId: String,
        listName: String,
        invitedId: String
    ) async throws {
        let dto = InvitationDTO(
            ownerName: ownerName,
            ownerEmail: ownerEmail,
            listId: listId,
            listName: listName,
            invitedId: invitedId,
            index: Date().milliseconds
        )
        try invitationsCollection.addDocument(from: dto)
    }

    /// Deletes an invitation
    /// - Parameter documentId: ID of the invitation document to delete
    /// - Throws: Error if the deletion fails
    func deleteInvitation(
        _ documentId: String
    ) async throws {
        try await invitationsCollection.document(documentId).delete()
    }

    /// Creates a Firestore query based on the provided search fields
    /// - Parameter fields: Array of search fields to filter invitations
    /// - Returns: A configured Firestore Query object
    private func invitationsQuery(
        with fields: [SearchField]
    ) -> Query {
        var query: Query = invitationsCollection

        fields.forEach {
            switch $0.filter {
            case .equal(let value):
                query = query.whereField($0.key.rawValue, isEqualTo: value)
            }
        }

        return query
    }
}
