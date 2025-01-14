import Foundation
import Entities
import Common
import Application
import CoordinatorContract
import HomeScreenContract

// MARK: - HomeReducer

typealias HomeData = Home.HomeData

extension Home {
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
			/// HomeReducer+ViewAppear
			case onViewAppear
			case onProfilePhotoAppear

			// MARK: - User actions
			/// HomeReducer+UserActions
			case didTapAcceptInvitation(String, String)
			case didTapDeclineInvitation(String)
			case didTapList(UUID)
			case didTapToggleListButton(UUID)
			case didTapDeleteListButton(UUID)
			case didTapShareListButton(UUID)
			case didTapEditListButton(UUID)
			case didTapUpdateListButton(UUID, String)
			case didTapCancelEditListButton(UUID)
			case didTapAddRowButton
			case didTapCancelAddListButton
			case didTapSubmitListButton(String)
			case didTapSignoutButton
			case didTapAboutButton
			case didSortLists(IndexSet, Int)
			case didTapDismissError
			case didTapConfirmDeleteAccount
			case didTapDismissDeleteAccount
			case didTapDeleteAccountButton
			case didTapAutoSortLists

			// MARK: - Results
			/// HomeReducer+Results
			case fetchDataResult(ActionResult<HomeData>)
			case getPhotoUrlResult(ActionResult<String>)
			case toggleListResult(ActionResult<UserList>)
			case deleteListResult(ActionResult<EquatableVoid>)
			case acceptInvitationResult(ActionResult<EquatableVoid>)
			case declineInvitationResult(ActionResult<EquatableVoid>)
			case addListResult(ActionResult<UserList>)
			case sortListsResult(ActionResult<EquatableVoid>)
			case deleteAccountResult(ActionResult<EquatableVoid>)
		}

		@MainActor
		struct State {
			var viewState = ViewState.idle
			var viewModel = ViewModel()
		}

		enum ViewState: Equatable {
			case idle
			case loading
			case addingList
			case sortingList
			case updatingList
			case editingList
			case alert(AlertStyle)
		}

		internal let dependencies: HomeScreenDependencies
        internal let useCase: HomeUseCaseApi = UseCase()

		init(dependencies: HomeScreenDependencies) {
			self.dependencies = dependencies
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

			case (_, .onProfilePhotoAppear):
				return onProfilePhotoAppear(
					state: &state
				)

			case (.idle, .didTapAcceptInvitation(let listId, let invitationId)):
				return onDidTapAcceptInvitation(
					state: &state,
					listId: listId,
					invitationId: invitationId
				)

			case (.idle, .didTapDeclineInvitation(let invitationId)):
				return onDidTapDeclineInvitation(
					state: &state,
					invitationId: invitationId
				)

			case (.idle, .didTapList(let rowId)):
				return onDidTapList(
					state: &state,
                    uid: rowId
				)

			case (.idle, .didTapToggleListButton(let rowId)):
				return onDidTapToggleListButton(
					state: &state,
                    uid: rowId
				)

			case (.idle, .didTapDeleteListButton(let rowId)):
				return onDidTapDeleteListButton(
					state: &state,
                    uid: rowId
				)

			case (.idle, .didTapShareListButton(let rowId)):
				return onDidTapShareListButton(
					state: &state,
                    uid: rowId
				)

			case (.idle, .didTapEditListButton(let rowId)):
				return onDidTapEditListButton(
					state: &state,
                    uid: rowId
				)

			case (.editingList, .didTapCancelEditListButton(let rowId)):
				return onDidTapCancelEditListButton(
					state: &state,
                    uid: rowId
				)

			case (.editingList, .didTapUpdateListButton(let uid, let name)):
				return onDidTapUpdateListButton(
					state: &state,
                    uid: uid,
					name: name
				)

			case (.idle, .didTapAddRowButton):
				return onDidTapAddRowButton(
					state: &state
				)

			case (.addingList, .didTapCancelAddListButton):
				return onDidTapCancelAddListButton(
					state: &state
				)

			case (.addingList, .didTapSubmitListButton(let name)):
				return onDidTapSubmitListButton(
					state: &state,
					newListName: name
				)

			case (.idle, .didTapSignoutButton):
				return onDidTapSignoutButton(
					state: &state
				)

			case (.idle, .didTapAboutButton):
				return onDidTapAboutButton(
					state: &state
				)

			case (.idle, .didSortLists(let fromIndex, let toIndex)):
				return onDidSortLists(
					state: &state,
					fromIndex: fromIndex,
					toIndex: toIndex
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

			case (.alert, .didTapDismissError):
				return onDidTapDismissError(
					state: &state
				)

			case (.idle, .didTapAutoSortLists):
				return onDidTapAutoSortLists(
					state: &state
				)

			case (.idle, .fetchDataResult(let result)),
				(.loading, .fetchDataResult(let result)):
				return onFetchDataResult(
					state: &state,
					result: result
				)

			case (_, .getPhotoUrlResult(let result)):
				return onPhotoUrlResult(
					state: &state,
					result: result
				)

			case (.updatingList, .toggleListResult(let result)):
				return onToggleListResult(
					state: &state,
					result: result
				)

			case (.updatingList, .deleteListResult(let result)):
				return onDeleteListResult(
					state: &state,
					result: result
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

			case (.addingList, .addListResult(let result)),
				(.editingList, .addListResult(let result)):
				return onAddListResult(
					state: &state,
					result: result
				)

			case (.sortingList, .sortListsResult(let result)):
				return onSortListsResult(
					state: &state,
					result: result
				)

			case (.alert, .deleteAccountResult(let result)):
				return onDeleteAccountResult(
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

// MARK: - UserList to ListRow

extension UserList {
	var toListRow: Home.Reducer.ListRow {
		Home.Reducer.ListRow(
			list: self,
			leadingActions: [self.done ? .undone : .done],
			trailingActions: [.delete, .share, .edit]
		)
	}
}
