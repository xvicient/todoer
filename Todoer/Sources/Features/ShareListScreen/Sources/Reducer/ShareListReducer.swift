import Entities
import Common
import Application
import CoordinatorContract
import ShareListScreenContract

// MARK: - ShareListReducer

extension ShareList {
    struct Reducer: Application.Reducer {

		enum Action: Equatable {
			// MARK: - View appear
			/// ShareListReducer+ViewAppear
			case onAppear

			// MARK: - User actions
			/// ShareListReducer+UserActions
			case didTapShareListButton(String, String)
			case didTapDismissError

			// MARK: - Results
			/// ShareListReducer+Results
			case fetchUsersResult(ActionResult<[User]>)
			case shareListResult(ActionResult<EquatableVoid>)
		}

		@MainActor
		struct State {
			var viewState = ViewState.idle
			var viewModel = ViewModel()
		}

		enum ViewState: Equatable {
			case idle
			case error(String)
		}

		internal let dependencies: ShareListScreenDependencies
        internal let useCase = UseCase()

		init(
			dependencies: ShareListScreenDependencies
		) {
			self.dependencies = dependencies
		}

		@MainActor
		func reduce(
			_ state: inout State,
			_ action: Action
		) -> Effect<Action> {

			switch (state.viewState, action) {
			case (.idle, .onAppear):
				return onAppear(
					state: &state
				)

			case (.idle, .didTapShareListButton(let email, let owner)):
				return onDidTapShareButton(
					state: &state,
					email: email,
                    owner: owner
				)

			case (.idle, .fetchUsersResult(let result)):
				return onFetchUsersResult(
					state: &state,
					result: result
				)

			case (.idle, .shareListResult(let result)):
				return onShareListResult(
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
