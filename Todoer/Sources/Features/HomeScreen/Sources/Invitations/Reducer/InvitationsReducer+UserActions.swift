import Foundation
import Entities
import Application

// MARK: - Reducer user actions

/// Extension containing user action handling methods for the Invitations Reducer
extension Invitations.Reducer {
    
    /// Handles accepting an invitation to a shared list
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - listId: ID of the list to accept
    ///   - invitationId: ID of the invitation being accepted
    /// - Returns: Effect to execute
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

    /// Handles declining an invitation to a shared list
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - listId: ID of the list being declined
    ///   - invitationId: ID of the invitation being declined
    /// - Returns: Effect to execute
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
