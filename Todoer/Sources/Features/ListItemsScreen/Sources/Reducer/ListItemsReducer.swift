import Foundation
import Entities
import Common
import Application
import Entities
import ListItemsScreenContract
import Strings

// MARK: - ListItemsReducer

protocol ListItemsReducerDependencies {
    var list: UserList { get }
    var useCase: ListItemsUseCaseApi { get }
}

extension ListItems {
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
			/// ListItemsReducer+ViewAppear
			case onAppear

			// MARK: - User actions
			/// ListItemsReducer+UserActions
			case didTapToggleItemButton(UUID)
			case didTapDeleteItemButton(UUID)
			case didTapAddRowButton
			case didTapCancelAddItemButton
			case didTapSubmitItemButton(String)
			case didTapEditItemButton(UUID)
			case didTapUpdateItemButton(UUID, String)
			case didTapCancelEditItemButton(UUID)
			case didSortItems(IndexSet, Int)
			case didTapDismissError
			case didTapAutoSortItems

			// MARK: - Results
			/// ListItemsReducer+Results
			case fetchItemsResult(ActionResult<[Item]>)
			case addItemResult(ActionResult<Item>)
			case deleteItemResult(ActionResult<EquatableVoid>)
			case toggleItemResult(ActionResult<Item>)
			case sortItemsResult(ActionResult<EquatableVoid>)
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
			case addingItem
			case updatingItem
			case editingItem
			case sortingItems
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

		internal let dependencies: ListItemsReducerDependencies

		init(dependencies: ListItemsReducerDependencies) {
			self.dependencies = dependencies
		}

		// MARK: - Reduce

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

			case (.idle, .didTapToggleItemButton(let rowId)):
				return onDidTapToggleItemButton(
					state: &state,
					uid: rowId
				)

			case (.idle, .didTapDeleteItemButton(let rowId)):
				return onDidTapDeleteItemButton(
					state: &state,
                    uid: rowId
				)

			case (.idle, .didTapAddRowButton):
				return onDidTapAddRowButton(
					state: &state
				)

			case (.addingItem, .didTapCancelAddItemButton):
				return onDidTapCancelAddRowButton(
					state: &state
				)

			case (.addingItem, .didTapSubmitItemButton(let newItemName)):
				return onDidTapSubmitItemButton(
					state: &state,
					newItemName: newItemName
				)

            // sortingItems uses firestore batch that triggers the collection listener so the fetch is being triggered as well
			case (.loading, .fetchItemsResult(let result)),
                (.idle, .fetchItemsResult(let result)),
                (.sortingItems, .fetchItemsResult(let result)),
                (.addingItem, .fetchItemsResult(let result)),
                (.editingItem, .fetchItemsResult(let result)):
				return onFetchItemsResult(
					state: &state,
					result: result
				)

			case (.addingItem, .addItemResult(let result)),
				(.editingItem, .addItemResult(let result)):
				return onAddItemResult(
					state: &state,
					result: result
				)

			case (.idle, .deleteItemResult):
				return .none

			case (.updatingItem, .toggleItemResult(let result)):
				return onToggleItemResult(
					state: &state,
					result: result
				)

			case (.idle, .didTapEditItemButton(let rowId)):
				return onDidTapEditItemButton(
					state: &state,
                    uid: rowId
				)

			case (.editingItem, .didTapCancelEditItemButton(let rowId)):
				return onDidTapCancelEditItemButton(
					state: &state,
                    uid: rowId
				)

			case (.editingItem, .didTapUpdateItemButton(let rowId, let name)):
				return onDidTapUpdateItemButton(
					state: &state,
                    uid: rowId,
					name: name
				)

			case (.idle, .didSortItems(let fromIndex, let toIndex)):
				return onDidSortItems(
					state: &state,
					fromIndex: fromIndex,
					toIndex: toIndex
				)

			case (.idle, .didTapAutoSortItems):
				return onDidTapAutoSortItems(
					state: &state
				)

            // As fetchItemsResult can be triggered by sortItemsResult first it will set the idle viewState
			case (.idle, .sortItemsResult(let result)),
                (.sortingItems, .sortItemsResult(let result)):
				return onSortItemsResult(
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

// MARK: - Item to ItemRow

extension Item {
	var toItemRow: ListItems.Reducer.WrappedItem {
		ListItems.Reducer.WrappedItem(
            id: id,
			item: self,
			leadingActions: [done ? .undone : .done],
			trailingActions: [.delete, .edit]
		)
	}
}
