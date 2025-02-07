import Foundation
import Common
import Application
import CoordinatorContract
import AppMenuContract
import SwiftUI
import Strings

// MARK: - MenuReducer

extension AppMenu {
    /// Reducer for handling app menu state and actions
    struct Reducer: Application.Reducer {
        
        /// Enumeration of possible errors in the app menu
        enum Errors: Error, LocalizedError {
            /// Represents an unexpected error
            case unexpectedError

            var errorDescription: String? {
                switch self {
                case .unexpectedError:
                    return "Unexpected error."
                }
            }

            /// Default error message
            static var `default`: String {
                Self.unexpectedError.localizedDescription
            }
        }

        /// Actions that can be performed in the app menu
        enum Action: Equatable {
            // MARK: - View appear
            /// Called when the view appears
            case onViewAppear
            
            // MARK: - User actions
            /// User tapped the sign out button
            case didTapSignoutButton
            /// User tapped the about button
            case didTapAboutButton
            /// User confirmed account deletion
            case didTapConfirmDeleteAccount
            /// User dismissed the delete account confirmation
            case didTapDismissDeleteAccount
            /// User tapped the delete account button
            case didTapDeleteAccountButton
            /// User dismissed an error alert
            case didTapDismissError

            // MARK: - Results
            /// Result of fetching the user's photo URL
            case getPhotoUrlResult(ActionResult<String>)
            /// Result of deleting the user's account
            case deleteAccountResult(ActionResult<EquatableVoid>)
        }

        /// State of the app menu
        @MainActor
        struct State: AppAlertState {
            /// Current view state (idle or showing alert)
            var viewState = ViewState.idle
            /// View model containing UI-related data
            var viewModel = ViewModel()
            
            /// Current alert being shown, if any
            var alert: AppAlert<Action>? {
                guard case .alert(let data) = viewState else {
                    return nil
                }
                return data
            }
        }

        /// Different states the view can be in
        enum ViewState {
            /// Initial state, ready for user input
            case idle
            /// Showing an alert
            case alert(AppAlert<Action>)
            
            /// Creates an error state with a custom message
            /// - Parameter message: Error message to display
            /// - Returns: ViewState configured to show an error alert
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

        /// Dependencies required by the app menu
        internal let dependencies: AppMenuDependencies
        /// Use case for handling menu operations
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

        // MARK: - Reduce

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
                Logger.log("No matching ViewState: \(state.viewState) and Action: \(action)")
                return .none
            }
        }
    }
}
