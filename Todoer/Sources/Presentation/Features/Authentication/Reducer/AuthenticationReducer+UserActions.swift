import Combine
import AuthenticationServices

// MARK: - Reducer user actions

@MainActor
internal extension Authentication.Reducer {
    func onDidTapGoogleSignInButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading
        return .task(Task {
            await .signInResult(
                dependencies.useCase.singIn(
                    provider: .google
                )
            )
        })
    }
    func onAppleSignIn(
        state: inout State,
        result: ActionResult<ASAuthorization>
    ) -> Effect<Action> {
        switch result {
        case .success(let authorization):
            state.viewState = .loading
            return .task(Task {
                await .signInResult(
                    dependencies.useCase.singIn(
                        provider: .apple(authorization)
                    )
                )
            })
        case .failure(let error):
            if error.code == 1001 || error.code == 1000 {
                state.viewState = .idle
            } else {
                state.viewState = .error(error.localizedDescription)
            }
        }
        return .none
    }
    
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
    }
}
