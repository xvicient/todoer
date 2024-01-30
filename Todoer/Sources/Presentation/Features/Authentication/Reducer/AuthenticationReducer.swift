import AuthenticationServices

protocol AuthenticationDependencies {
    var useCase: AuthenticationUseCaseApi { get }
}

extension Authentication {
    struct Reducer: Todoer.Reducer {
        
        enum Action: Equatable {
            static func == (
                lhs: Authentication.Reducer.Action,
                rhs: Authentication.Reducer.Action
            ) -> Bool {
                switch (lhs, rhs) {
                case (.didTapGoogleSignInButton, .didTapGoogleSignInButton),
                    (.didAppleSignIn, .didAppleSignIn),
                    (.signInResult, .signInResult),
                    (.didTapDismissError, .didTapDismissError):
                    return true
                default: return false
                }
            }
            
            // MARK: - User actions
            case didTapGoogleSignInButton
            case didAppleSignIn(Result<ASAuthorization, Error>)
            
            // MARK: - Results
            case signInResult(Result<Void, Error>)
            
            // MARK: - Errors
            case didTapDismissError
        }
        
        @MainActor
        struct State {
            var viewState = ViewState.idle
            var viewModel = ViewModel()
        }
        
        enum ViewState: Equatable {
            case idle
            case loading
            case error(String)
        }
        
        internal let coordinator: Coordinator
        internal let dependencies: AuthenticationDependencies
        
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
}
