import Combine
import Foundation

// MARK: - ShareListReducer

protocol ShareListDependencies {
    var useCase: ShareListUseCaseApi { get }
    var listUids: [String] { get }
}

extension ShareList {
    struct Reducer: Listio.Reducer {
        
        enum Action {
            // MARK: - View flow start
            case viewWillAppear
            
            // MARK: - Results
            case fetchUsersResult(Result<[User], Error>)
        }
        
        @MainActor
        struct State {
            var users: [User] = []
        }
        
        private let dependencies: ShareListDependencies
        
        init(dependencies: ShareListDependencies) {
            self.dependencies = dependencies
        }
        
        @MainActor
        func reduce(
            _ state: inout State,
            _ action: Action
        ) -> Effect<Action> {
            
            switch action {
            case .viewWillAppear:
                return onViewWillAppear(
                    state: &state
                )
                
            case .fetchUsersResult(let result):
                if case .success(let users) = result {
                    state.users = users
                }
                return .none
            }
        }
    }
}

// MARK: - Reducer actions

@MainActor
private extension ShareList.Reducer {
    func onViewWillAppear(
        state: inout State
    ) -> Effect<Action> {
        .task(Task {
            .fetchUsersResult(
                await dependencies.useCase.fetchUsers(
                    uids: dependencies.listUids
                )
            )
        })
    }
}
