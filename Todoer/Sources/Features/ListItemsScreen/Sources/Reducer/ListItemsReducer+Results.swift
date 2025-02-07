import Entities
import Application

// MARK: - Reducer results

/// Extension handling all result actions in the ListItems reducer
@MainActor
extension ListItems.Reducer {
    /// Handles the result of fetching items
    /// - Parameters:
    ///   - state: Current state of the reducer
    ///   - result: Result containing either the fetched items or an error
    /// - Returns: No effect is produced
    func onFetchItemsResult(
        state: inout State,
        result: ActionResult<[Item]>
    ) -> Effect<Action> {
        switch result {
        case .success(let items):
            state.viewState = .idle
            state.viewModel.items = items.map { $0.toItemRow }
            state.viewModel.listName = dependencies.list.name
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }

    /// Handles the result of adding a new item
    /// - Parameters:
    ///   - state: Current state of the reducer
    ///   - result: Result containing either the added item or an error
    /// - Returns: No effect is produced
    func onAddItemResult(
        state: inout State,
        result: ActionResult<Item>
    ) -> Effect<Action> {
        switch result {
        case .success(let item):
            if let index = state.viewModel.items.firstIndex(where: { $0.isEditing }) {
                state.viewState = .idle
                state.viewModel.items.remove(at: index)
                state.viewModel.items.insert(item.toItemRow, at: index)
            }
            else {
                state.viewState = .error(Errors.default)
            }
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }

    /// Handles the dismissal of an error alert
    /// - Parameter state: Current state of the reducer
    /// - Returns: No effect is produced
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
    }

    /// Handles the result of toggling an item's completion status
    /// - Parameters:
    ///   - state: Current state of the reducer
    ///   - result: Result indicating success or failure of the toggle operation
    /// - Returns: No effect is produced
    func onToggleItemResult(
        state: inout State,
        result: ActionResult<Item>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .error(Errors.default)
        }
        return .none
    }

    /// Handles the result of sorting items
    /// - Parameters:
    ///   - state: Current state of the reducer
    ///   - result: Result indicating success or failure of the sort operation
    /// - Returns: No effect is produced
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
