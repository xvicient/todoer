import AuthenticationServices
import Common

protocol AuthenticationDependencies {
	var useCase: AuthenticationUseCaseApi { get }
}

extension Authentication {
	struct Reducer: Todoer.Reducer {

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

		internal let coordinator: any CoordinatorApi
		internal let dependencies: AuthenticationDependencies

		init(
			coordinator: any CoordinatorApi,
			dependencies: AuthenticationDependencies
		) {
			self.coordinator = coordinator
			self.dependencies = dependencies
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
