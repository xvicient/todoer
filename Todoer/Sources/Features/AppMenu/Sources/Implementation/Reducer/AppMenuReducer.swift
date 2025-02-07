import Foundation
import Common
import xRedux
import CoordinatorContract
import AppMenuContract
import SwiftUI
import Strings

extension AppMenu {
    
    /// Reducer for handling app menu state and actions
	struct Reducer: xRedux.Reducer {
        
        /// Enumeration of possible errors in the app menu
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

        /// Actions that can be performed in the app menu
		enum Action: Equatable, StringRepresentable {
			/// MenuReducer+ViewAppear
			case onViewAppear
            
            /// MenuReducer+UserActions
            case didTapSignoutButton
            case didTapAboutButton
            case didTapConfirmDeleteAccount
            case didTapDismissDeleteAccount
            case didTapDeleteAccountButton
            case didTapDismissError
            
			/// MenuReducer+Results
			case getPhotoUrlResult(ActionResult<String>)
            case deleteAccountResult(ActionResult<EquatableVoid>)
		}

        /// State of the app menu
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

        enum ViewState: StringRepresentable {
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

        /// Initializes the reducer with required dependencies
        /// - Parameters:
        ///   - dependencies: Menu dependencies
        ///   - useCase: Menu use case
        init(
            dependencies: AppMenuDependencies,
            useCase: MenuUseCaseApi
        ) {
            self.dependencies = dependencies
            self.useCase = useCase
        }

        /// Reduces the current state and action to produce a new state and side effects
        /// - Parameters:
        ///   - state: Current state of the app menu
        ///   - action: Action to process
        /// - Returns: Effect to be executed as a result of the action
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
                Logger.log("No matching ViewState: \(state.viewState.rawValue) and Action: \(action.rawValue)")
				return .none
			}
		}
	}
}
