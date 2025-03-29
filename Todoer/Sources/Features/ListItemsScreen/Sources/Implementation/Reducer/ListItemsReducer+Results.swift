import Entities
import xRedux

// MARK: - Reducer results

extension ListItems.Reducer {
    func onFetchItemsResult(
        state: inout State,
        result: ActionResult<[Item]>
    ) -> Effect<Action> {
        switch result {
        case .success(let items):
            if case .loading = state.viewState { state.viewState = .idle }
            state.items = items
            return .none
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }
    
    func onAddItemResult(
        state: inout State,
        result: ActionResult<Item>
    ) -> Effect<Action> {
        switch result {
        case .success(let item):
            guard let index = state.items.firstIndex(where: \.isEditing) else {
                state.viewState = .error()
                return .none
            }
            state.items.replace(item, at: index)
            state.viewState = .idle
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }
    
    func onUpdateItemResult(
        state: inout State,
        result: ActionResult<Item>
    ) -> Effect<Action> {
        switch result {
        case .success(let item):
            guard let index = state.items.firstIndex(where: { $0.id == $0.id }) else {
                state.viewState = .error()
                return .none
            }
            state.items.replace(item, at: index)
            state.viewState = .updating
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }
    
    func onMoveItemResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success: break
        case .failure:
            state.viewState = .error()
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
    
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
    }
}

fileprivate extension Item {
    func hasChanges(comparedTo item: Item) -> Bool {
        name != item.name || done != item.done
    }
    
    mutating func update(with item: Item) {
        if name != item.name {
            name = item.name
        }
        if done != item.done {
            done = item.done
        }
    }
}
