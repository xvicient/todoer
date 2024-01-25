import AuthenticationServices

protocol AuthenticationDependencies {
    var useCase: AuthenticationUseCaseApi { get }
}

extension Authentication {
    struct Reducer: Todoer.Reducer {
        
        enum Action {
            // MARK: - User actions
            case didTapGoogleSignInButton
            case didAppleSignIn(Result<ASAuthorization, Error>)
            
            // MARK: - Results
            case signInResult(Result<Void, Error>)
            
            // MARK: - Errors
            case didTapDismissError
        }
        
        struct State {
            var viewState = ViewState.idle
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
    }
}
