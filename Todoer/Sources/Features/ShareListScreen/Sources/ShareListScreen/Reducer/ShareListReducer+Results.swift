import Entities
import Application

// MARK: - Reducer results

@MainActor
extension ShareList.Reducer {
	func onFetchUsersResult(
		state: inout State,
		result: ActionResult<[User]>
	) -> Effect<Action> {
		if case .success(let users) = result {
			state.viewModel.users = users
		}
		return .none
	}

	func onShareListResult(
		state: inout State,
		result: ActionResult<EquatableVoid>
	) -> Effect<Action> {
		switch result {
		case .success:
			state.viewState = .idle
			coordinator.dismissSheet()
		case .failure(let error):
			state.viewState = .error(error.localizedDescription)
		}
		return .none
	}
}
