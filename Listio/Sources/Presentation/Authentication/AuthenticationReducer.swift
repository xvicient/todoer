protocol AuthenticationDependencies {
    var useCase: AuthenticationUseCaseApi { get }
}

extension Authentication {
    struct Reducer: Listio.Reducer {
        
        enum Action {
            case didTapSignInButton
            case signInSucceed
            case signInError
        }
        
        struct State {
            var isLoading: Bool = false
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
        
        func reduce(
            _ state: inout State,
            _ action: Action
        ) -> Effect<Action> {
            switch action {
            case .didTapSignInButton:
                state.isLoading = true
                
                return .task(Task {
                    do {
                        try await dependencies.useCase.signIn()
                        return .signInSucceed
                    } catch {
                        return .signInError
                    }
                })
                
            case .signInSucceed:
                state.isLoading = false
                coordinator.loggIn()
            case .signInError:
                state.isLoading = false
                coordinator.loggOut()
            }
            
            return .none
        }
    }
}
