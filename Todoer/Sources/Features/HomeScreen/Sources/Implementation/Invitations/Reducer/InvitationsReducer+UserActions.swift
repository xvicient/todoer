import Entities
import Foundation
import xRedux

// MARK: - Reducer user actions

extension Invitations.Reducer {

    func onDidTapAcceptInvitation(
        state: inout State,
        listId: String,
        invitationId: String
    ) -> Effect<Action> {
        return .task { send in
            await send(
                .acceptInvitationResult(
                    useCase.acceptInvitation(
                        listId: listId,
                        invitationId: invitationId
                    )
                )
            )
        }
    }

    func onDidTapDeclineInvitation(
        state: inout State,
        listId: String,
        invitationId: String
    ) -> Effect<Action> {
        return .task { send in
            await send(
                .declineInvitationResult(
                    useCase.declineInvitation(
                        listId: listId,
                        invitationId: invitationId
                    )
                )
            )
        }
    }
}
