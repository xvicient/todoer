import Foundation

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
            
        case .signInSucceed, .signInError:
            state.isLoading = false
        }
        
        return nil
    }
}
