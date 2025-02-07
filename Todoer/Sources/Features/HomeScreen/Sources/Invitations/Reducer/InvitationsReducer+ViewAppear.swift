import Combine
import Application

// MARK: - View appear

/// Extension containing view appearance handling for the Invitations Reducer
extension Invitations.Reducer {
    /// Handles the view's appearance by initializing the view model with invitations
    /// - Parameter state: Current state to modify
    /// - Returns: Effect to execute
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        state.viewModel.invitations = invitations
        return .none
    }
}
