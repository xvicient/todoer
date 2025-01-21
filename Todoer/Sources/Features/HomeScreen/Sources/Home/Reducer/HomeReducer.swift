import Foundation
import Entities
import Common
import Application
import CoordinatorContract
import HomeScreenContract
import Strings

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

			// MARK: - User actions
			/// HomeReducer+UserActions
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
			case didSortLists(IndexSet, Int)
			case didTapDismissError
			case didTapAutoSortLists

			// MARK: - Results
			/// HomeReducer+Results
			case fetchDataResult(ActionResult<HomeData>)
			case toggleListResult(ActionResult<UserList>)
			case deleteListResult(ActionResult<EquatableVoid>)
			case addListResult(ActionResult<UserList>)
			case sortListsResult(ActionResult<EquatableVoid>)
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

		enum ViewState: Equatable {
			case idle
			case loading
			case addingList
			case sortingList
			case updatingList
			case editingList
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

			case (.idle, .didSortLists(let fromIndex, let toIndex)):
				return onDidSortLists(
					state: &state,
					fromIndex: fromIndex,
					toIndex: toIndex
				)

			case (.alert, .didTapDismissError):
				return onDidTapDismissError(
					state: &state
				)

			case (.idle, .didTapAutoSortLists):
				return onDidTapAutoSortLists(
					state: &state
				)
            
            // sortingList uses firestore batch that triggers the collection listener so the fetch is being triggered as well
			case (.idle, .fetchDataResult(let result)),
                (.loading, .fetchDataResult(let result)),
                (.sortingList, .fetchDataResult(let result)):
				return onFetchDataResult(
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

			case (.addingList, .addListResult(let result)),
				(.editingList, .addListResult(let result)):
				return onAddListResult(
					state: &state,
					result: result
				)

            // As fetchDataResult can be triggered by sortListsResult first it will set the idle viewState
			case (.idle, .sortListsResult(let result)),
                (.sortingList, .sortListsResult(let result)):
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
	var toListRow: Home.Reducer.WrappedUserList {
		Home.Reducer.WrappedUserList(
            id: id,
			list: self,
			leadingActions: [done ? .undone : .done],
			trailingActions: [.delete, .share, .edit]
		)
	}
}
