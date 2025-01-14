import AuthenticationServices
import Common
import Application

// MARK: - Reducer results

@MainActor
extension Authentication.Reducer {
	func onSignInResult(
		state: inout State,
		result: ActionResult<EquatableVoid>
	) -> Effect<Action> {
		switch result {
		case .success:
			state.viewState = .idle
            dependencies.coordinator.loggIn()
		case .failure(let error):
			if error.code == -5 {
				state.viewState = .idle
			}
			else {
				state.viewState = .error(error.localizedDescription)
			}
		}
		return .none
	}
}
