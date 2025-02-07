import Combine
import Foundation
import Data
import Application
import Entities

/// Protocol defining the use case API for managing invitations
protocol InvitationsUseCaseApi {
    /// Accepts an invitation to join a shared list
    /// - Parameters:
    ///   - listId: ID of the list to join
    ///   - invitationId: ID of the invitation to accept
    /// - Returns: Result indicating success with list ID or failure with error
    func acceptInvitation(
        listId: String,
        invitationId: String
    ) async -> ActionResult<String>

    /// Declines an invitation to join a shared list
    /// - Parameters:
    ///   - listId: ID of the list being declined
    ///   - invitationId: ID of the invitation to decline
    /// - Returns: Result indicating success with list ID or failure with error
    func declineInvitation(
        listId: String,
        invitationId: String
    ) async -> ActionResult<String>
}

extension Invitations {
    
    /// Implementation of the InvitationsUseCaseApi protocol
    struct UseCase: InvitationsUseCaseApi {
        
        /// Repository for managing todo lists
        private let listsRepository: ListsRepositoryApi
        /// Repository for managing invitations
        private let invitationsRepository: InvitationsRepositoryApi

        /// Creates a new UseCase instance
        /// - Parameters:
        ///   - listsRepository: Repository for managing todo lists
        ///   - invitationsRepository: Repository for managing invitations
        init(
            listsRepository: ListsRepositoryApi = ListsRepository(),
            invitationsRepository: InvitationsRepositoryApi = InvitationsRepository()
        ) {
            self.listsRepository = listsRepository
            self.invitationsRepository = invitationsRepository
        }
        
        func acceptInvitation(
            listId: String,
            invitationId: String
        ) async -> ActionResult<String> {
            do {
                try await listsRepository.importList(id: listId)
                try await invitationsRepository.deleteInvitation(invitationId)
                return .success(listId)
            }
            catch {
                return .failure(error)
            }
        }
        
        func declineInvitation(
            listId: String,
            invitationId: String
        ) async -> ActionResult<String> {
            do {
                try await invitationsRepository.deleteInvitation(invitationId)
                return .success(listId)
            }
            catch {
                return .failure(error)
            }
        }
    }
}
