import AuthenticationScreenContract
import AuthenticationServices
import Common
import CoordinatorContract
import Strings
import xRedux

extension Authentication {
    struct Reducer: xRedux.Reducer {

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

        enum Action: Equatable, StringRepresentable {
            // MARK: - User actions
            case didTapGoogleSignInButton
            case didAppleSignIn(ActionResult<ASAuthorization>)

            // MARK: - Results
            case signInResult(ActionResult<EquatableVoid>)

            // MARK: - Errors
            case didTapDismissError
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

        enum ViewState: Equatable, StringRepresentable {
            case idle
            case loading
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
                Logger.log(
                    "No matching ViewState: \(state.viewState.rawValue) and Action: \(action.rawValue)"
                )
                return .none
            }
        }
    }
}
