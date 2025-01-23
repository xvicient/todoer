import Foundation
import Application
import AppMenuContract
import Common
import Strings

/// Extension containing user action handling methods for the App Menu Reducer
extension AppMenu.Reducer {
    
    /// Handles the user tapping the sign out button
    /// - Parameter state: Current state of the app menu
    /// - Returns: Effect that processes the sign out action
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

    /// Handles the user tapping the about button
    /// - Parameter state: Current state of the app menu
    /// - Returns: Effect that navigates to the about screen
    @MainActor
    func onDidTapAboutButton(
		state: inout State
	) -> Effect<Action> {
		dependencies.coordinator.push(.about)
		return .none
	}
    
    /// Handles the user tapping the delete account button
    /// - Parameter state: Current state of the app menu
    /// - Returns: Effect that shows the delete account confirmation alert
    func onDidTapDeleteAccountButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .alert(
            .init(
                message: Strings.AppMenu.deleteAccountConfirmationText,
                primaryAction: (.didTapConfirmDeleteAccount, Strings.AppMenu.deleteButtonTitle),
                secondaryAction: (.didTapDismissDeleteAccount, Strings.AppMenu.cancelButtonTitle)
            )
        )
        return .none
	}

    /// Handles the user confirming account deletion
    /// - Parameter state: Current state of the app menu
    /// - Returns: Effect that initiates the account deletion process
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

    /// Handles the user dismissing the delete account confirmation
    /// - Parameter state: Current state of the app menu
    /// - Returns: Effect that resets the view state to idle
	func onDidTapDismissDeleteAccount(
		state: inout State
	) -> Effect<Action> {
		state.viewState = .idle
		return .none
	}
    
    /// Handles the user dismissing an error alert
    /// - Parameter state: Current state of the app menu
    /// - Returns: Effect that resets the view state to idle
    func onDidTapDismissError(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle
        return .none
    }
}
