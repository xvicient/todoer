import Foundation
import Combine

extension Authentication {
    typealias Store = Listio.Store<State, Action, Dependencies>
    
    struct Dependencies {
        var useCase = UseCase()
    }
    
    enum Action {
        case didTapSignInButton
        case signInSucceed
        case signInError
    }
    
    struct State {
        var isLoading: Bool = false
    }
    
    static func reducer(
        state: inout State,
        action: Action,
        dependencies: Dependencies
    ) -> AnyPublisher<Action, Never> {
        switch action {
        case .didTapSignInButton:
            state.isLoading = true
            return dependencies.useCase.signIn()
                .map { .signInSucceed }
                .catch { _ in Just(.signInError) }
                .eraseToAnyPublisher()

        case .signInSucceed, .signInError:
            state.isLoading = false
        }
        
        return Empty().eraseToAnyPublisher()
    }
}
