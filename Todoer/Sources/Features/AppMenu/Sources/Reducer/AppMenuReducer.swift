import Foundation
import Common
import Application
import CoordinatorContract
import AppMenuContract
import SwiftUI
import Strings

// MARK: - MenuReducer

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
        struct State: AppAlertState {
			var viewState = ViewState.idle
			var viewModel = ViewModel()
            
            var alert: AppAlert<Action>? {
                guard case .alert(let data) = viewState else {
                    return nil
                    
                }
                return data
            }
		}

		enum ViewState {
			case idle
			case alert(AppAlert<Action>)
            
            static func error(
                _ message: String = Errors.default
            ) -> ViewState {
                .alert(
                    .init(
                        title: Strings.Errors.errorTitle,
                        message: message,
                        primaryAction: (.didTapDismissError, Strings.Errors.okButtonTitle)
                    )
                )
            }
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
