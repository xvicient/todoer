import Combine
import Foundation

// MARK: - ShareListReducer

protocol ShareListDependencies {
    var coordinator: Coordinator { get }
    var useCase: ShareListUseCaseApi { get }
    var list: List { get }
}

extension ShareList {
    struct Reducer: Listio.Reducer {
        
        enum Action {
            // MARK: - View flow start
            case viewWillAppear
            
            // MARK: - User actions
            case didTapShareListButton
            
            // MARK: - Results
            case fetchUsersResult(Result<[User], Error>)
            case shareListResult(Result<Void, Error>)
            
            // MARK: - View bindings
            case setShareEmail(String)
        }
        
        @MainActor
        struct State {
            var users = [User]()
            var shareEmail = ""
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
                
            case .didTapShareListButton:
                return onDidTapShareButton(
                    state: &state
                )
                
            case .fetchUsersResult(let result):
                if case .success(let users) = result {
                    state.users = users
                }
                return .none
                
            case .shareListResult(let result):
                if case .success = result {
                    dependencies.coordinator.dismissSheet()
                }
                return .none
                
            case .setShareEmail(let email):
                state.shareEmail = email
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
                    uids: dependencies.list.uuid
                )
            )
        })
    }
    func onDidTapShareButton(
        state: inout State
    ) -> Effect<Action> {
        let shareEmail = state.shareEmail
        return .task(Task {
            .shareListResult(
                await dependencies.useCase.shareList(
                    shareEmail: shareEmail,
                    list: dependencies.list
                )
            )
        })
    }
}
