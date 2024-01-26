// MARK: - Reducer results

@MainActor
internal extension ListItems.Reducer {    
    func onFetchItemsResult(
        state: inout State,
        result: Result<[Item], Error>
    ) -> Effect<Action> {
        switch result {
        case .success(let items):
            state.viewState = .idle
            state.viewModel.items = items.map { $0.toItemRow }
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }
    
    func onAddItemResult(
        state: inout State,
        result: Result<Item, Error>
    ) -> Effect<Action> {
        switch result {
        case .success(let item):
            state.viewState = .idle
            state.viewModel.items.removeAll { $0.isEditing }
            state.viewModel.items.append(item.toItemRow)
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
    
    func onToggleItemResult(
        state: inout State,
        result: Result<Item, Error>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .error(ListItems.Errors.unexpectedError.localizedDescription)
        }
        return .none
    }
}

// MARK: - Item to ItemRow

private extension Item {
    var toItemRow: ListItems.Reducer.ItemRow {
        ListItems.Reducer.ItemRow(
            item: self,
            leadingActions: [self.done ? .undone : .done],
            trailingActions: [.delete, .edit]
        )
    }
}
