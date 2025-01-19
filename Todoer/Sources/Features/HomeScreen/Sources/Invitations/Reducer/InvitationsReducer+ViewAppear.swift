import Combine
import Application

// MARK: - View appear

extension Invitations.Reducer {
	func onAppear(
		state: inout State
	) -> Effect<Action> {
        state.viewState = .idle
        state.viewModel.invitations = invitations
        return .none
	}
}
