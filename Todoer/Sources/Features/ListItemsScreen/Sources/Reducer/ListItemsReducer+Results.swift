import Entities
import Application

// MARK: - Reducer results

@MainActor
extension ListItems.Reducer {
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

	func onDidTapDismissError(
		state: inout State
	) -> Effect<Action> {
		state.viewState = .idle
		return .none
	}

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
