import AuthenticationServices
import Common
import Application

// MARK: - Reducer results

/// Extension containing result handling methods for the Authentication Reducer
@MainActor
extension Authentication.Reducer {
    /// Handles the result of a sign-in attempt
    /// - Parameters:
    ///   - state: Current state of the authentication screen
    ///   - result: Result of the sign-in operation
    /// - Returns: Effect to be executed as a result of handling the sign-in result
    func onSignInResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
            dependencies.coordinator.loggIn()
        case .failure(let error):
            // Error code -5 indicates user cancelled the operation
            if error.code == -5 {
                state.viewState = .idle
            }
            else {
                state.viewState = .error(error.localizedDescription)
            }
        }
        return .none
    }
}
