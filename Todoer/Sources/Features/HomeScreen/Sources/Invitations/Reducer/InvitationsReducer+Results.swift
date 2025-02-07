import Entities
import Application

// MARK: - Reducer results

/// Extension containing result handling methods for the Invitations Reducer
@MainActor
extension Invitations.Reducer {

    /// Handles the result of accepting an invitation
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - result: Result of the accept invitation operation
    /// - Returns: Effect to execute
    func onAcceptInvitationResult(
        state: inout State,
        result: ActionResult<String>
    ) -> Effect<Action> {
        switch result {
        case .success(let listId):
            state.viewState = .idle
            state.viewModel.invitations.removeAll { $0.listId == listId }
        case .failure:
            state.viewState = .alert(Errors.default)
        }
        return .none
    }

    /// Handles the result of declining an invitation
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - result: Result of the decline invitation operation
    /// - Returns: Effect to execute
    func onDeclineInvitationResult(
        state: inout State,
        result: ActionResult<String>
    ) -> Effect<Action> {
        switch result {
        case .success(let listId):
            state.viewState = .idle
            state.viewModel.invitations.removeAll { $0.listId == listId }
        case .failure:
            state.viewState = .alert(Errors.default)
        }
        return .none
    }
}
