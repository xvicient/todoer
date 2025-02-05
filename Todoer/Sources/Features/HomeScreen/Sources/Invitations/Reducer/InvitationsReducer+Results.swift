import Entities
import xRedux

// MARK: - Reducer results

@MainActor
extension Invitations.Reducer {

	func onAcceptInvitationResult(
		state: inout State,
		result: ActionResult<String>
	) -> Effect<Action> {
		switch result {
		case .success(let listId):
			state.viewState = .idle
            state.viewModel.invitations.removeAll { $0.listId == listId }
		case .failure:
			state.viewState = .alert(Errors.default)
		}
		return .none
	}

	func onDeclineInvitationResult(
		state: inout State,
		result: ActionResult<String>
	) -> Effect<Action> {
		switch result {
		case .success(let listId):
			state.viewState = .idle
            state.viewModel.invitations.removeAll { $0.listId == listId }
		case .failure:
			state.viewState = .alert(Errors.default)
		}
		return .none
	}
}
