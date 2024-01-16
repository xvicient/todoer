protocol AuthenticationDependencies {
    var useCase: AuthenticationUseCaseApi { get }
}

extension Authentication {
    struct Reducer: Todoo.Reducer {
        
        enum Action {
            // MARK: - User actions
            case didTapGoogleSignInButton
            case didTapAppleSignInButton
            
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
