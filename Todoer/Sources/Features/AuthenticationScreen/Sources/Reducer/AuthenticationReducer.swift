/// Namespace for Authentication feature components
enum Authentication {
    /// Main reducer for the Authentication feature
    /// Handles state management and business logic
    struct Reducer: Application.Reducer {
        
        /// Enumeration of possible errors in the authentication process
        enum Errors: Error, LocalizedError {
            /// Represents an unexpected error during authentication
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

        /// Actions that can be performed in the authentication flow
        enum Action: Equatable {
            // MARK: - User actions
            /// User tapped the Google sign-in button
            case didTapGoogleSignInButton
            /// Result of Apple sign-in attempt
            case didAppleSignIn(ActionResult<ASAuthorization>)

            // MARK: - Results
            /// Result of the sign-in process
            case signInResult(ActionResult<EquatableVoid>)

            // MARK: - Errors
            /// User dismissed an error alert
            case didTapDismissError
        }

        /// State of the authentication screen
        @MainActor
        struct State: AppAlertState {
            /// Current view state (idle, loading, or showing alert)
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
        enum ViewState: Equatable {
            /// Initial state, ready for user input
            case idle
            /// Loading state during authentication
            case loading
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

        /// Dependencies required by the authentication screen
        internal let dependencies: AuthenticationScreenDependencies
        /// Use case for handling authentication logic
        internal let useCase: AuthenticationUseCaseApi

        /// Initializes the reducer with required dependencies
        /// - Parameters:
        ///   - dependencies: Screen dependencies
        ///   - useCase: Authentication use case
        init(
            dependencies: AuthenticationScreenDependencies,
            useCase: AuthenticationUseCaseApi
        ) {
            self.dependencies = dependencies
            self.useCase = useCase
        }

        /// Reduces the current state and action to produce a new state and side effects
        /// - Parameters:
        ///   - state: Current state of the authentication screen
        ///   - action: Action to process
        /// - Returns: Effect to be executed as a result of the action
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
