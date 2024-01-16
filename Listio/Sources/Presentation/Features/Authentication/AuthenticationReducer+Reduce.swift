import Combine

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
            
        case (.idle, .didTapAppleSignInButton):
            return onDidTapAppleSignInButton(
                state: &state
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
            await .signInResult(dependencies.useCase.googleSignIn())
        })
    }
    func onDidTapAppleSignInButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading
        return .task(Task {
            await .signInResult(dependencies.useCase.appleSignIn())
        })
    }
    
    func onSignInResult(
        state: inout State,
        result: Result<Void, Error>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
            coordinator.loggIn()
        case .failure:
            state.viewState = .unexpectedError
            coordinator.loggOut()
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
