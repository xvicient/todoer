import SwiftUI

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
        private let useCase: Authentication.UseCase
        
        init(coordinator: Coordinator, useCase: Authentication.UseCase) {
            self.coordinator = coordinator
            self.useCase = useCase
        }
        
        func reduce(_ state: inout State, _ action: Action) -> Task<Action, Never>? {
            switch action {
            case .didTapSignInButton:
                state.isLoading = true
                return Task {
                    do {
                        try await useCase.signIn()
                        return .signInSucceed
                    } catch {
                        return .signInError
                    }
                }
                
            case .signInSucceed, .signInError:
                state.isLoading = false
                coordinator.push(.home)
            }
            
            return nil
        }
    }
}
