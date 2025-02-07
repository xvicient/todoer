import Combine
import Entities
import Foundation

public protocol InvitationsRepositoryApi {
    func getInvitations() -> AnyPublisher<[Invitation], Error>

    func getInvitation(
        invitedId: String,
        listId: String
    ) async throws -> Invitation?

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

public final class InvitationsRepository: InvitationsRepositoryApi {

    typealias SearchField = InvitationsDataSource.SearchField

    let invitationsDataSource: InvitationsDataSourceApi = InvitationsDataSource()
    let usersDataSource: UsersDataSourceApi = UsersDataSource()

    public init() {}

    public func getInvitations() -> AnyPublisher<[Invitation], Error> {
        invitationsDataSource.getInvitations(
            with: [SearchField(.invitedId, .equal(usersDataSource.uid))]
        )
        .tryMap { invitations in
            invitations.map(\.toDomain)
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

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
        .map(\.toDomain)
        .first
    }

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

    public func deleteInvitation(
        _ documentId: String
    ) async throws {
        try await invitationsDataSource.deleteInvitation(documentId)
    }
}

extension InvitationDTO {
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
