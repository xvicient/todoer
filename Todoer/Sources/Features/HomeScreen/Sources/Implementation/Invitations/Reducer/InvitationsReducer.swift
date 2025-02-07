import Common
import Entities
import Foundation
import xRedux

// MARK: - HomeReducer

extension Invitations {
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
            // MARK: - View appear
            /// InvitationsReducer+ViewAppear
            case onViewAppear

            // MARK: - User actions
            /// InvitationsReducer+UserActions
            case didTapAcceptInvitation(String, String)
            case didTapDeclineInvitation(String, String)

            // MARK: - Results
            /// InvitationsReducer+Results
            case acceptInvitationResult(ActionResult<String>)
            case declineInvitationResult(ActionResult<String>)
        }

        @MainActor
        struct State {
            var viewState = ViewState.idle
            var viewModel = ViewModel()
        }

        enum ViewState: Equatable, StringRepresentable {
            case idle
            case alert(String)
        }

        internal let useCase: InvitationsUseCaseApi
        internal let invitations: [Invitation]

        init(
            invitations: [Invitation],
            useCase: InvitationsUseCaseApi = UseCase()
        ) {
            self.invitations = invitations
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

            case (.idle, .didTapAcceptInvitation(let listId, let invitationId)):
                return onDidTapAcceptInvitation(
                    state: &state,
                    listId: listId,
                    invitationId: invitationId
                )

            case (.idle, .didTapDeclineInvitation(let listId, let invitationId)):
                return onDidTapDeclineInvitation(
                    state: &state,
                    listId: listId,
                    invitationId: invitationId
                )

            case (_, .acceptInvitationResult(let result)):
                return onAcceptInvitationResult(
                    state: &state,
                    result: result
                )

            case (_, .declineInvitationResult(let result)):
                return onDeclineInvitationResult(
                    state: &state,
                    result: result
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
