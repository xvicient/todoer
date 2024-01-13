import Combine
import Foundation

protocol InvitationsRepositoryApi {
    func fetchInvitations(
    ) -> AnyPublisher<[Invitation], Error>
    
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
    let invitationsDataSource: InvitationsDataSourceApi
    let usersDataSource: UsersDataSourceApi
    
    init(invitationsDataSource: InvitationsDataSourceApi = InvitationsDataSource(),
         usersDataSource: UsersDataSourceApi = UsersDataSource()) {
        self.invitationsDataSource = invitationsDataSource
        self.usersDataSource = usersDataSource
    }
    
    func fetchInvitations(
    ) -> AnyPublisher<[Invitation], Error> {
        invitationsDataSource.fetchInvitations(uuid: usersDataSource.uuid)
            .tryMap { invitations in
                invitations.map {
                    $0.toDomain
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
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
                   dateCreated: dateCreated)
    }
}
