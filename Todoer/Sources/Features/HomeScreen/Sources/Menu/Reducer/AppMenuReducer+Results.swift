import Entities
import Application

// MARK: - Reducer results

@MainActor
extension AppMenu.Reducer {
	func onPhotoUrlResult(
		state: inout State,
		result: ActionResult<String>
	) -> Effect<Action> {
		state.viewState = .idle
		switch result {
		case .success(let photoUrl):
			state.viewModel.photoUrl = photoUrl
		case .failure:
			break
		}
		return .none
	}

	func onDeleteAccountResult(
		state: inout State,
		result: ActionResult<EquatableVoid>
	) -> Effect<Action> {
		switch result {
		case .success:
			state.viewState = .idle
			dependencies.coordinator.loggOut()
		case .failure:
			state.viewState = .alert(.error(Errors.default))
		}
		return .none
	}
}
