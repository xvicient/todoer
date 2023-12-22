import SwiftUI

protocol AuthenticationReducerDependencies {
    var useCase: Authentication.UseCase { get }
}

extension Authentication {
    struct Reducer: Listio.Reducer {
        typealias Dependencies = AuthenticationReducerDependencies
        
        enum Action {
            case didTapSignInButton
            case signInSucceed
            case signInError
        }
        
        struct State {
            var isLoading: Bool = false
        }
        
        private let coordinator: Coordinator
        private let dependencies: Dependencies
        
        init(coordinator: Coordinator, dependencies: Dependencies) {
            self.coordinator = coordinator
            self.dependencies = dependencies
        }
        
        func reduce(
            _ state: inout State,
            _ action: Action
        ) -> Task<Action, Never>? {
            switch action {
            case .didTapSignInButton:
                state.isLoading = true
                return Task {
                    do {
                        try await dependencies.useCase.signIn()
                        return .signInSucceed
                    } catch {
                        return .signInError
                    }
                }
                
            case .signInSucceed:
                state.isLoading = false
                coordinator.loggIn()
            case .signInError:
                state.isLoading = false
                coordinator.loggOut()
            }
            
            return nil
        }
    }
}
