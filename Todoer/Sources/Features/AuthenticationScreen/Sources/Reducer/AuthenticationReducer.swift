import AuthenticationServices
import Common
import Application
import CoordinatorContract
import AuthenticationScreenContract

extension Authentication {
	struct Reducer: Application.Reducer {

		enum Action: Equatable {
			// MARK: - User actions
			case didTapGoogleSignInButton
			case didAppleSignIn(ActionResult<ASAuthorization>)

			// MARK: - Results
			case signInResult(ActionResult<EquatableVoid>)

			// MARK: - Errors
			case didTapDismissError
		}

		@MainActor
		struct State {
			var viewState = ViewState.idle
			var viewModel = ViewModel()
		}

		enum ViewState: Equatable {
			case idle
			case loading
			case error(String)
		}

		internal let dependencies: AuthenticationScreenDependencies
        internal let useCase: AuthenticationUseCaseApi

		init(
			dependencies: AuthenticationScreenDependencies,
            useCase: AuthenticationUseCaseApi
		) {
			self.dependencies = dependencies
            self.useCase = useCase
		}

		@MainActor
		func reduce(
			_ state: inout State,
			_ action: Action
		) -> Effect<Action> {
			switch (state.viewState, action) {
			case (.idle, .didTapGoogleSignInButton):
				return onDidTapGoogleSignInButton(
					state: &state
				)

			case (.idle, .didAppleSignIn(let result)):
				return onAppleSignIn(
					state: &state,
					result: result
				)

			case (.loading, .signInResult(let result)):
				return onSignInResult(
					state: &state,
					result: result
				)

			case (_, .didTapDismissError):
				return onDidTapDismissError(
					state: &state
				)

			default:
				Logger.log("No matching ViewState: \(state.viewState) and Action: \(action)")
				return .none
			}
		}
	}
}
