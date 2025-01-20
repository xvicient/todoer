import Foundation
import Application
import AppMenuContract
import Common

// MARK: - Reducer user actions

extension AppMenu.Reducer {
    
    @MainActor
	func onDidTapSignoutButton(
		state: inout State
	) -> Effect<Action> {
		switch useCase.signOut() {
		case .success:
			dependencies.coordinator.loggOut()
		case .failure:
            state.viewState = .error()
		}
		return .none
	}

    @MainActor
    func onDidTapAboutButton(
		state: inout State
	) -> Effect<Action> {
		dependencies.coordinator.push(.about)
		return .none
	}
    
    func onDidTapDeleteAccountButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .alert(
            .init(
                message: Strings.deleteAccountConfirmation,
                primaryAction: (.didTapConfirmDeleteAccount, Strings.deleteButton),
                secondaryAction: (.didTapDismissDeleteAccount, Strings.cancelButton)
            )
        )
        return .none
	}

	func onDidTapConfirmDeleteAccount(
		state: inout State
	) -> Effect<Action> {
		return .task { send in
			await send(
				.deleteAccountResult(
					useCase.deleteAccount()
				)
			)
		}
	}

	func onDidTapDismissDeleteAccount(
		state: inout State
	) -> Effect<Action> {
		state.viewState = .idle
		return .none
	}
    
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
    }
}
