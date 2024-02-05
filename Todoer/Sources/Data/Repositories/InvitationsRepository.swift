import Combine
import Foundation

protocol InvitationsRepositoryApi {
    func getInvitations(
    ) -> AnyPublisher<[Invitation], Error>
    
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

final class InvitationsRepository: InvitationsRepositoryApi {
    
    typealias SearchField = InvitationsDataSource.SearchField
    
    let invitationsDataSource: InvitationsDataSourceApi
    let usersDataSource: UsersDataSourceApi
    
    init(invitationsDataSource: InvitationsDataSourceApi = InvitationsDataSource(),
         usersDataSource: UsersDataSourceApi = UsersDataSource()) {
        self.invitationsDataSource = invitationsDataSource
        self.usersDataSource = usersDataSource
    }
    
    func getInvitations(
    ) -> AnyPublisher<[Invitation], Error> {
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
    
    func getInvitation(
        invitedId: String,
        listId: String
    ) async throws -> Invitation? {
        try await invitationsDataSource.getInvitations(
            with: [SearchField(.invitedId, .equal(invitedId)),
                   SearchField(.listId, .equal(listId))]
        )
        .map { $0.toDomain }
        .first
    }
    
    func sendInvitation(
        ownerName: String,
        ownerEmail: String,
        listId: String,
        listName: String,
        invitedId: String
    ) async throws {
        try await invitationsDataSource.sendInvitation(ownerName: ownerName,
                                                       ownerEmail: ownerEmail,
                                                       listId: listId,
                                                       listName: listName,
                                                       invitedId: invitedId)
    }
    
    func deleteInvitation(
        _ documentId: String
    ) async throws {
        try await invitationsDataSource.deleteInvitation(documentId)
    }
}

private extension InvitationDTO {
    var toDomain: Invitation {
        Invitation(documentId: id ?? "",
                   ownerName: ownerName,
                   ownerEmail: ownerEmail,
                   listId: listId,
                   listName: listName,
                   invitedId: invitedId,
                   index: index)
    }
}
