import Combine

// MARK: - ShareList Reducer

internal extension ShareList.Reducer {    
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
            return onFetchDataResult(
                state: &state,
                result: result
            )
            
        case (_, .didTapDismissError):
            return onDidTapDismissError(
                state: &state
            )
            
        default:
            Logger.log("No matching ViewState: \(state.viewState) and Action: \(action)")
            return .none
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
    
    func onFetchDataResult(
        state: inout State,
        result: Result<Void, Error>
    ) -> Effect<Action> {
        switch result {
        case .success():
            state.viewState = .idle
            dependencies.coordinator.dismissSheet()
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }
    
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
    }
}
