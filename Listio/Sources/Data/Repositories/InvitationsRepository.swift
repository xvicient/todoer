import Combine
import Foundation

protocol InvitationsRepositoryApi {
    func fetchInvitations(
    ) -> AnyPublisher<[Invitation], Error>
    func fetchInvitations(
        completion: @escaping (Result<[Invitation], Error>) -> Void
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
    
    func fetchInvitations(
        completion: @escaping (Result<[Invitation], Error>) -> Void
    ) {
        invitationsDataSource.fetchInvitations(uuid: usersDataSource.uuid) { result in
            switch result {
            case .success(let dto):
                completion(.success(
                    dto.map {
                        $0.toDomain
                    }
                ))
            case .failure(let error):
                completion(.failure(error))
            }
        }
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
        _ documentId: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        invitationsDataSource.deleteInvitation(documentId, completion: completion)
    }
}
