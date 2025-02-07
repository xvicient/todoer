import Combine
import Data
import Entities
import Foundation
import xRedux

protocol InvitationsUseCaseApi {

    func acceptInvitation(
        listId: String,
        invitationId: String
    ) async -> ActionResult<String>

    func declineInvitation(
        listId: String,
        invitationId: String
    ) async -> ActionResult<String>
}

extension Invitations {

    struct UseCase: InvitationsUseCaseApi {

        private let listsRepository: ListsRepositoryApi
        private let invitationsRepository: InvitationsRepositoryApi
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
