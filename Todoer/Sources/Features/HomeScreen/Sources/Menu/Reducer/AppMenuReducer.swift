import Foundation
import Entities
import Common
import Application
import CoordinatorContract
import HomeScreenContract

// MARK: - MenuReducer

public protocol AppMenuDependencies {
    var coordinator: CoordinatorApi { get }
}

extension AppMenu {
	struct Reducer: Application.Reducer {
        
        enum Errors: Error, LocalizedError {
            case unexpectedError

            var errorDescription: String? {
                switch self {
                case .unexpectedError:
                    return "Unexpected error."
                }
            }

            static var `default`: String {
                Self.unexpectedError.localizedDescription
            }
        }

		enum Action: Equatable {
			// MARK: - View appear
			/// MenuReducer+ViewAppear
			case onViewAppear
            
            // MARK: - User actions
            /// MenuReducer+UserActions
            case didTapSignoutButton
            case didTapAboutButton
            case didTapConfirmDeleteAccount
            case didTapDismissDeleteAccount
            case didTapDeleteAccountButton
            case didTapDismissError
            

			// MARK: - Results
			/// MenuReducer+Results
			case getPhotoUrlResult(ActionResult<String>)
            case deleteAccountResult(ActionResult<EquatableVoid>)
		}

		@MainActor
		struct State {
			var viewState = ViewState.idle
			var viewModel = ViewModel()
		}

		enum ViewState: Equatable {
			case idle
			case alert(AlertStyle)
		}

        internal let dependencies: AppMenuDependencies
        internal let useCase: MenuUseCaseApi

        init(
            dependencies: AppMenuDependencies,
            useCase: MenuUseCaseApi
        ) {
            self.dependencies = dependencies
            self.useCase = useCase
        }

		// MARK: - Reduce

		@MainActor
		func reduce(
			_ state: inout State,
			_ action: Action
		) -> Effect<Action> {

			switch (state.viewState, action) {
			case (.idle, .onViewAppear):
				return onAppear(
					state: &state
				)

			case (.idle, .didTapSignoutButton):
				return onDidTapSignoutButton(
					state: &state
				)

			case (.idle, .didTapAboutButton):
				return onDidTapAboutButton(
					state: &state
				)

			case (.idle, .didTapDeleteAccountButton):
				return onDidTapDeleteAccountButton(
					state: &state
				)

			case (.alert, .didTapConfirmDeleteAccount):
				return onDidTapConfirmDeleteAccount(
					state: &state
				)

			case (.alert, .didTapDismissDeleteAccount):
				return onDidTapDismissDeleteAccount(
					state: &state
				)

			case (_, .getPhotoUrlResult(let result)):
				return onPhotoUrlResult(
					state: &state,
					result: result
				)

			case (.alert, .deleteAccountResult(let result)):
				return onDeleteAccountResult(
					state: &state,
					result: result
				)
                
            case (.alert, .didTapDismissError):
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
