import Foundation
import Entities
import Common
import Application

// MARK: - InvitationsReducer

extension Invitations {
    /// Reducer that manages the state and actions for the invitations feature
    struct Reducer: Application.Reducer {

        /// Possible errors that can occur in the invitations feature
        enum Errors: Error, LocalizedError {
            /// Represents an unexpected error condition
            case unexpectedError

            /// Localized description of the error
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

        /// Actions that can be performed in the invitations feature
        enum Action: Equatable {
            // MARK: - View appear
            /// InvitationsReducer+ViewAppear
            case onViewAppear

            // MARK: - User actions
            /// InvitationsReducer+UserActions
            /// Action to accept an invitation with list and invitation IDs
            case didTapAcceptInvitation(String, String)
            /// Action to decline an invitation with list and invitation IDs
            case didTapDeclineInvitation(String, String)

            // MARK: - Results
            /// InvitationsReducer+Results
            /// Result of accepting an invitation
            case acceptInvitationResult(ActionResult<String>)
            /// Result of declining an invitation
            case declineInvitationResult(ActionResult<String>)
        }

        /// State for the invitations feature
        @MainActor
        struct State {
            /// Current view state
            var viewState = ViewState.idle
            /// View model containing UI data
            var viewModel = ViewModel()
        }

        /// Possible view states for the invitations feature
        enum ViewState: Equatable {
            /// Default state when no action is being performed
            case idle
            /// State when an alert needs to be shown
            case alert(String)
        }

        /// Use case for handling invitation-related operations
        internal let useCase: InvitationsUseCaseApi
        /// List of pending invitations
        internal let invitations: [Invitation]

        /// Creates a new InvitationsReducer
        /// - Parameters:
        ///   - invitations: List of pending invitations
        ///   - useCase: Use case for handling invitation operations
        init(
            invitations: [Invitation],
            useCase: InvitationsUseCaseApi = UseCase()
        ) {
            self.invitations = invitations
            self.useCase = useCase
        }

        // MARK: - Reduce

        /// Processes an action and updates the state accordingly
        /// - Parameters:
        ///   - state: Current state to modify
        ///   - action: Action to process
        /// - Returns: Effect to execute
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
                Logger.log("No matching ViewState: \(state.viewState) and Action: \(action)")
                return .none
            }
        }
    }
}
