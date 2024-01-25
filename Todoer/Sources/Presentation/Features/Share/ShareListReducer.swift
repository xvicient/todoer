import Combine
import Foundation

// MARK: - ShareListReducer

protocol ShareListDependencies {
    var coordinator: Coordinator { get }
    var useCase: ShareListUseCaseApi { get }
    var list: List { get }
}

extension ShareList {
    struct Reducer: Todoer.Reducer {
        
        enum Action {
            // MARK: - View appear
            case onAppear
            
            // MARK: - User actions
            case didTapShareListButton(String)
            
            // MARK: - Results
            case fetchUsersResult(Result<[User], Error>)
            case shareListResult(Result<Void, Error>)
            
            // MARK: - Errors
            case didTapDismissError
        }
        
        @MainActor
        struct State {
            var users = [User]()
            var viewState = ViewState.idle
        }
        
        enum ViewState: Equatable {
            case idle
            case error(String)
        }
        
        internal let dependencies: ShareListDependencies
        
        init(dependencies: ShareListDependencies) {
            self.dependencies = dependencies
        }
    }
}
