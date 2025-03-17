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
            guard let editingIndex = state.items.firstIndex(where: { $0.isEditing }),
                  var editingRow = state.items[safe: editingIndex],
                  let remoteItem = items.first(where: { $0.documentId == editingRow.item.documentId })
            else {
                state.viewState = .idle
                state.items = items.map { $0.toItemRow }
                return .none
            }
            
            // Update editing item
            if editingRow.item.hasChanges(comparedTo: remoteItem) {
                editingRow.item.update(with: remoteItem)
                state.items[editingIndex] = editingRow
            } else {
                state.viewState = .idle
                state.items = items.map { $0.toItemRow }
                return .none
            }
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
            if let index = state.items.firstIndex(where: { $0.isEditing }) {
                state.viewState = .idle
                state.items.replace(item: item, at: index)
            }
            else {
                state.viewState = .error(Errors.default)
            }
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }

    func onDeleteItemResult(
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

    func onToggleItemResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .error(Errors.default)
        }
        return .none
    }

    func onSortItemsResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .error(Errors.default)
        }
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
