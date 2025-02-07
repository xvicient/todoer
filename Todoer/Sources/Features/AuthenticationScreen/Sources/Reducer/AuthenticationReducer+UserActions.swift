import AuthenticationServices
import Combine
import Application

// MARK: - Reducer user actions

/// Extension containing user action handling methods for the Authentication Reducer
extension Authentication.Reducer {
    /// Handles the user tapping the Google Sign-In button
    /// - Parameter state: Current state of the authentication screen
    /// - Returns: Effect that initiates the Google sign-in process
    func onDidTapGoogleSignInButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading
        return .task { send in
            await send(
                .signInResult(
                    useCase.singIn(
                        provider: .google
                    )
                )
            )
        }
    }

    /// Handles the result of Apple Sign-In
    /// - Parameters:
    ///   - state: Current state of the authentication screen
    ///   - result: Result of the Apple sign-in attempt
    /// - Returns: Effect that processes the Apple sign-in result
    func onAppleSignIn(
        state: inout State,
        result: ActionResult<ASAuthorization>
    ) -> Effect<Action> {
        switch result {
        case .success(let authorization):
            state.viewState = .loading
            return .task { send in
                await send(
                    .signInResult(
                        useCase.singIn(
                            provider: .apple(authorization)
                        )
                    )
                )
            }
        case .failure(let error):
            // Error codes 1001 and 1000 indicate user cancelled or invalid response
            if error.code == 1001 || error.code == 1000 {
                state.viewState = .idle
            }
            else {
                state.viewState = .error(error.localizedDescription)
            }
        }
        return .none
    }

    /// Handles the user dismissing an error alert
    /// - Parameter state: Current state of the authentication screen
    /// - Returns: Effect that resets the view state to idle
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
    }
}
