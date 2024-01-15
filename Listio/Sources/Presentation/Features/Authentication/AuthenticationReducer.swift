protocol AuthenticationDependencies {
    var useCase: AuthenticationUseCaseApi { get }
}

extension Authentication {
    struct Reducer: Listio.Reducer {
        
        enum Action {
            // MARK: - User actions
            case didTapSignInButton
            
            // MARK: - Results
            case signInResult(Result<Void, Error>)
            
            // MARK: - Errors
            case didTapDismissError
        }
        
        struct State {
            var viewState = ViewState.idle
        }
        
        enum ViewState {
            case idle
            case loading
            case unexpectedError
        }
        
        private let coordinator: Coordinator
        private let dependencies: AuthenticationDependencies
        
        init(
            coordinator: Coordinator,
            dependencies: AuthenticationDependencies
        ) {
            self.coordinator = coordinator
            self.dependencies = dependencies
        }
        
        @MainActor 
        func reduce(
            _ state: inout State,
            _ action: Action
        ) -> Effect<Action> {
            switch (state.viewState, action) {
            case (.idle, .didTapSignInButton):
                return onDidTapSignInButton(
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
}

// MARK: - Reducer actions

@MainActor
private extension Authentication.Reducer {
    func onDidTapSignInButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading
        return .task(Task {
            await .signInResult(dependencies.useCase.signIn())
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
