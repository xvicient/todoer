import Combine
import AuthenticationServices

// MARK: - Authentication Reducer

internal extension Authentication.Reducer {
    @MainActor
    func reduce(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action> {
        switch (state.viewState, action) {
        case (.idle, .didTapGoogleSignInButton):
            return onDidTapGoogleSignInButton(
                state: &state
            )
            
        case (.idle, .didAppleSignIn(let result)):
            return onAppleSignIn(
                state: &state,
                result: result
            )
            
        case (.loading, .signInResult(let result)):
            return onSignInResult(
                state: &state,
                result: result
            )
            
        case (_, .didTapDismissError):
            return onDidTapDismissError(
                state: &state
            )
            
        default: return .none
        }
    }
}

// MARK: - Reducer actions

@MainActor
private extension Authentication.Reducer {
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
        result: Result<ASAuthorization, Error>
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
            if error.code == 1001 {
                state.viewState = .idle
            } else {
                state.viewState = .error(error.localizedDescription)
            }
        }
        return .none
    }
    
    func onSignInResult(
        state: inout State,
        result: Result<Void, Error>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
            coordinator.loggIn()
        case .failure(let error):
            switch error {
            case Authentication.UseCase.Errors.emailInUse:
                state.viewState = .error(error.localizedDescription)
            default:
                if error.code == -5 {
                    state.viewState = .idle
                } else {
                    state.viewState = .error(error.localizedDescription)
                }
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
