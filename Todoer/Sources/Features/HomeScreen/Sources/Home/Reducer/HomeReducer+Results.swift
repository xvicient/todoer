import Entities
import Application

// MARK: - Reducer results

/// Extension containing result handling methods for the Home Reducer
@MainActor
extension Home.Reducer {
    /// Handles the result of fetching home data
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - result: Result containing home data or error
    /// - Returns: Effect to execute
    func onFetchDataResult(
        state: inout State,
        result: ActionResult<HomeData>
    ) -> Effect<Action> {
        switch result {
        case .success(let data):
            state.viewState = .idle
            state.viewModel.lists = data.lists.map { $0.toListRow }
            state.viewModel.invitations = data.invitations
        case .failure:
            state.viewState = .error()
        }
        return .none
    }

    /// Handles the result of toggling a list's status
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - result: Result containing updated list or error
    /// - Returns: Effect to execute
    func onToggleListResult(
        state: inout State,
        result: ActionResult<UserList>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .error()
        }
        return .none
    }

    /// Handles the result of deleting a list
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - result: Result indicating success or error
    /// - Returns: Effect to execute
    func onDeleteListResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .error()
        }
        return .none
    }

    /// Handles the result of adding a new list
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - result: Result containing new list or error
    /// - Returns: Effect to execute
    func onAddListResult(
        state: inout State,
        result: ActionResult<UserList>
    ) -> Effect<Action> {
        guard let index = state.viewModel.lists.firstIndex(where: { $0.isEditing }) else {
            state.viewState = .error()
            return .none
        }
        state.viewModel.lists.remove(at: index)

        switch result {
        case .success(let list):
            state.viewModel.lists.insert(list.toListRow, at: index)
            state.viewState = .idle
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }

    /// Handles the result of sorting lists
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - result: Result indicating success or error
    /// - Returns: Effect to execute
    func onSortListsResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .error()
        }
        return .none
    }

    /// Handles the result of deleting the user's account
    /// - Parameters:
    ///   - state: Current state to modify
    ///   - result: Result indicating success or error
    /// - Returns: Effect to execute
    func onDeleteAccountResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
            dependencies.coordinator.loggOut()
        case .failure:
            state.viewState = .error()
        }
        return .none
    }
}
