import Entities
import xRedux

// MARK: - Reducer results

extension Home.Reducer {

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

    func onAddSharedListsResult(
        state: inout State,
        result: ActionResult<[UserList]>
    ) -> Effect<Action> {
        state.viewState = .idle
        switch result {
        case .success(let lists):
            if !lists.isEmpty {
                state.viewModel.lists.insert(contentsOf: lists.map { $0.toListRow }, at: 0)
            }
        case .failure:
            break
        }
        return .none
    }

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

    @MainActor
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
