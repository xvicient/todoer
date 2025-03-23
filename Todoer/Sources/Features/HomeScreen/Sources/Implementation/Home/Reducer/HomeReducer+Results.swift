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
            if case .loading = state.viewState { state.viewState = .idle }
            state.lists = data.lists
            state.invitations = data.invitations
            return .none
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
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
                state.lists.insert(contentsOf: lists.map { $0 }, at: 0)
            }
        case .failure:
            break
        }
        return .none
    }
    
    func onAddListResult(
        state: inout State,
        result: ActionResult<UserList>
    ) -> Effect<Action> {
        switch result {
        case .success(let list):
            guard let index = state.lists.firstIndex(where: \.isEditing) else {
                state.viewState = .error()
                return .none
            }
            state.lists.replace(list, at: index)
            state.viewState = .idle
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }
    
    func onUpdateListResult(
        state: inout State,
        result: ActionResult<UserList>
    ) -> Effect<Action> {
        switch result {
        case .success(let list):
            guard let index = state.lists.firstIndex(where: { $0.id == $0.id }) else {
                state.viewState = .error()
                return .none
            }
            state.lists.replace(list, at: index)
            state.viewState = .updating
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }

    func onVoidResult(
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
}

fileprivate extension UserList {
    func hasChanges(comparedTo list: UserList) -> Bool {
        name != list.name || done != list.done
    }
    
    mutating func update(with list: UserList) {
        if name != list.name {
            name = list.name
        }
        if done != list.done {
            done = list.done
        }
    }
}
