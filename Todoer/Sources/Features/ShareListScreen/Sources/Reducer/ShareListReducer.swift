import Foundation
import Entities
import Common
import Application
import CoordinatorContract
import ShareListScreenContract
import Strings

// MARK: - ShareListReducer

typealias ShareData = ShareList.ShareData

extension ShareList {
    struct Reducer: Application.Reducer {
        
        internal enum Errors: Error, LocalizedError {
            case missingUserName
            case unexpectedError

            var errorDescription: String? {
                switch self {
                case .missingUserName:
                    return "User name not found."
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
			/// ShareListReducer+ViewAppear
			case onAppear

			// MARK: - User actions
			/// ShareListReducer+UserActions
			case didTapShareListButton(String, String)
			case didTapDismissError

			// MARK: - Results
			/// ShareListReducer+Results
            case fetchDataResult(ActionResult<ShareData>)
			case shareListResult(ActionResult<EquatableVoid>)
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

		enum ViewState: Equatable {
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

		internal let dependencies: ShareListScreenDependencies
        internal let useCase: ShareListUseCaseApi

		init(
			dependencies: ShareListScreenDependencies,
            useCase: ShareListUseCaseApi
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
