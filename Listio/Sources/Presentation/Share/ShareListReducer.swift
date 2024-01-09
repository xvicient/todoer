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
            // MARK: - View appear
            case onAppear
            
            // MARK: - User actions
            case didTapShareListButton(String)
            
            // MARK: - Results
            case fetchUsersResult(Result<[User], Error>)
            case shareListResult(Result<Void, Error>)
        }
        
        @MainActor
        struct State {
            var users = [User]()
            var viewState = ViewState.idle
        }
        
        enum ViewState {
            case idle
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
            
            switch (state.viewState, action) {
            case (.idle, .onAppear):
                return onAppear(
                    state: &state
                )
                
            case (.idle, .didTapShareListButton(let email)):
                return onDidTapShareButton(
                    state: &state,
                    email: email
                )
                
            case (.idle, .fetchUsersResult(let result)):
                if case .success(let users) = result {
                    state.users = users
                }
                return .none
                
            case (.idle, .shareListResult(let result)):
                if case .success = result {
                    dependencies.coordinator.dismissSheet()
                }
                return .none
            }
        }
    }
}

// MARK: - Reducer actions

@MainActor
private extension ShareList.Reducer {
    func onAppear(
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
        state: inout State,
        email: String
    ) -> Effect<Action> {
        return .task(Task {
            .shareListResult(
                await dependencies.useCase.shareList(
                    shareEmail: email,
                    list: dependencies.list
                )
            )
        })
    }
}
