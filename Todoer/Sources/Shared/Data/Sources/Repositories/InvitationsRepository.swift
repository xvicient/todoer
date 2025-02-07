import Combine
import Foundation
import Entities

/// Protocol defining the API for managing list sharing invitations
public protocol InvitationsRepositoryApi {
    /// Retrieves all invitations for the current user
    /// - Returns: A publisher that emits an array of invitations or an error
    func getInvitations() -> AnyPublisher<[Invitation], Error>

    /// Retrieves a specific invitation
    /// - Parameters:
    ///   - invitedId: ID of the user being invited
    ///   - listId: ID of the list being shared
    /// - Returns: The invitation if found, nil otherwise
    /// - Throws: Error if retrieval fails
    func getInvitation(
        invitedId: String,
        listId: String
    ) async throws -> Invitation?

    /// Sends a new invitation to share a list
    /// - Parameters:
    ///   - ownerName: Name of the list owner
    ///   - ownerEmail: Email of the list owner
    ///   - listId: ID of the list being shared
    ///   - listName: Name of the list being shared
    ///   - invitedId: ID of the user being invited
    /// - Throws: Error if sending fails
    func sendInvitation(
        ownerName: String,
        ownerEmail: String,
        listId: String,
        listName: String,
        invitedId: String
    ) async throws

    /// Deletes an invitation
    /// - Parameter documentId: ID of the invitation document to delete
    /// - Throws: Error if deletion fails
    func deleteInvitation(
        _ documentId: String
    ) async throws
}

/// Implementation of InvitationsRepositoryApi using Firebase Firestore
public final class InvitationsRepository: InvitationsRepositoryApi {

    /// Type alias for search field to improve code readability
    typealias SearchField = InvitationsDataSource.SearchField

    /// Data source for managing invitations in Firestore
    let invitationsDataSource: InvitationsDataSourceApi = InvitationsDataSource()
    /// Data source for managing users in Firestore
    let usersDataSource: UsersDataSourceApi = UsersDataSource()

    /// Creates a new invitations repository
    public init() {}

    /// Retrieves all invitations for the current user
    /// - Returns: A publisher that emits an array of invitations or an error
    public func getInvitations() -> AnyPublisher<[Invitation], Error> {
        invitationsDataSource.getInvitations(
            with: [SearchField(.invitedId, .equal(usersDataSource.uid))]
        )
        .tryMap { invitations in
            invitations.map {
                $0.toDomain
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    /// Retrieves a specific invitation
    /// - Parameters:
    ///   - invitedId: ID of the user being invited
    ///   - listId: ID of the list being shared
    /// - Returns: The invitation if found, nil otherwise
    /// - Throws: Error if retrieval fails
    public func getInvitation(
        invitedId: String,
        listId: String
    ) async throws -> Invitation? {
        try await invitationsDataSource.getInvitations(
            with: [
                SearchField(.invitedId, .equal(invitedId)),
                SearchField(.listId, .equal(listId)),
            ]
        )
        .map { $0.toDomain }
        .first
    }

    /// Sends a new invitation to share a list
    /// - Parameters:
    ///   - ownerName: Name of the list owner
    ///   - ownerEmail: Email of the list owner
    ///   - listId: ID of the list being shared
    ///   - listName: Name of the list being shared
    ///   - invitedId: ID of the user being invited
    /// - Throws: Error if sending fails
    public func sendInvitation(
        ownerName: String,
        ownerEmail: String,
        listId: String,
        listName: String,
        invitedId: String
    ) async throws {
        try await invitationsDataSource.sendInvitation(
            ownerName: ownerName,
            ownerEmail: ownerEmail,
            listId: listId,
            listName: listName,
            invitedId: invitedId
        )
    }

    /// Deletes an invitation
    /// - Parameter documentId: ID of the invitation document to delete
    /// - Throws: Error if deletion fails
    public func deleteInvitation(
        _ documentId: String
    ) async throws {
        try await invitationsDataSource.deleteInvitation(documentId)
    }
}

/// Extension to convert InvitationDTO to domain model
extension InvitationDTO {
    /// Converts the DTO to a domain model
    fileprivate var toDomain: Invitation {
        Invitation(
            documentId: id ?? "",
            ownerName: ownerName,
            ownerEmail: ownerEmail,
            listId: listId,
            listName: listName,
            invitedId: invitedId,
            index: index
        )
    }
}
