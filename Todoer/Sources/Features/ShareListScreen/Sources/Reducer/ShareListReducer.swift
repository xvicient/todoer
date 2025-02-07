import Foundation
import Entities
import Common
import Application
import CoordinatorContract
import ShareListScreenContract
import Strings

typealias ShareData = ShareList.ShareData

/// Namespace for ShareList feature components
extension ShareList {
    /// Main reducer for the ShareList feature
    /// Handles state management and business logic
    struct Reducer: Application.Reducer {
        
        /// Possible errors that can occur in the ShareList feature
        internal enum Errors: Error, LocalizedError {
            /// Indicates that the user name is missing
            case missingUserName
            /// Indicates an unexpected error occurred
            case unexpectedError

            var errorDescription: String? {
                switch self {
                case .missingUserName:
                    return "User name not found."
                case .unexpectedError:
                    return "Unexpected error."
                }
            }
            
            /// Default error message
            static var `default`: String {
                Self.unexpectedError.localizedDescription
            }
        }

        /// Actions that can be performed in the ShareList feature
        enum Action: Equatable {
            // MARK: - View appear
            /// ShareListReducer+ViewAppear
            case onAppear

            // MARK: - User actions
            /// ShareListReducer+UserActions
            /// Action to share a list with another user
            case didTapShareListButton(String, String)
            /// Action to dismiss an error alert
            case didTapDismissError

            // MARK: - Results
            /// ShareListReducer+Results
            /// Result of fetching share data
            case fetchDataResult(ActionResult<ShareData>)
            /// Result of sharing a list
            case shareListResult(ActionResult<EquatableVoid>)
        }

        /// State for the ShareList feature
        @MainActor
        struct State: AppAlertState {
            /// Current view state
            var viewState = ViewState.idle
            /// View model containing UI data
            var viewModel = ViewModel()
            
            /// Current alert being displayed, if any
            var alert: AppAlert<Action>? {
                guard case .alert(let data) = viewState else {
                    return nil
                    
                }
                return data
            }
        }

        /// Possible view states for the ShareList feature
        enum ViewState: Equatable {
            /// Default state, ready for user interaction
            case idle
            /// Displaying an alert
            case alert(AppAlert<Action>)
            
            /// Creates an error state with a message
            /// - Parameter message: Error message to display
            /// - Returns: A ViewState with an error alert
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

        /// Dependencies required by the reducer
        internal let dependencies: ShareListScreenDependencies
        /// Use case containing business logic
        internal let useCase: ShareListUseCaseApi

        /// Initializes a new ShareList reducer
        /// - Parameters:
        ///   - dependencies: Required dependencies for the feature
        ///   - useCase: Use case containing business logic
        init(
            dependencies: ShareListScreenDependencies,
            useCase: ShareListUseCaseApi
        ) {
            self.dependencies = dependencies
            self.useCase = useCase
        }

        /// Handles state updates based on actions
        /// - Parameters:
        ///   - state: Current state to update
        ///   - action: Action to handle
        /// - Returns: Effect to execute
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

            case (.idle, .fetchDataResult(let result)):
                return onFetchDataResult(
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
