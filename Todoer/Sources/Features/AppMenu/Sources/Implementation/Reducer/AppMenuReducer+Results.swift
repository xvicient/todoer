import xRedux
import AppMenuContract

/// Extension containing result handling methods for the App Menu Reducer
@MainActor
extension AppMenu.Reducer {
    
    /// Handles the result of fetching the user's photo URL
    /// - Parameters:
    ///   - state: Current state of the app menu
    ///   - result: Result containing either the photo URL or an error
    /// - Returns: Effect to be executed as a result of handling the photo URL result
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

    /// Handles the result of deleting the user's account
    /// - Parameters:
    ///   - state: Current state of the app menu
    ///   - result: Result indicating success or failure of the account deletion
    /// - Returns: Effect to be executed as a result of handling the account deletion
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
