// MARK: - Reducer results

@MainActor
internal extension ShareList.Reducer {
    func onFetchUsersResult(
        state: inout State,
        result: Result<[User], Error>
    ) -> Effect<Action> {
        if case .success(let users) = result {
            state.viewModel.users = users
        }
        return .none
    }
    
    func onShareListResult(
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
}
