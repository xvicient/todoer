import xRedux
import Common

extension ListItems.Reducer {
    func reduce(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action> {
        switch (state.viewState, action) {
        case (.loading, .onAppear):
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
            
        case (.idle, .didUpdateSearchText(let text)):
            return onDidUpdateSearchText(
                state: &state,
                searchText: text
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

        case (_, .fetchItemsResult(let result)):
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

        case (.updatingItem, .deleteItemResult(let result)):
            return onDeleteItemResult(
                state: &state,
                result: result
            )

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

        case (.sortingItems, .sortItemsResult(let result)):
            return onSortItemsResult(
                state: &state,
                result: result
            )

        case (.alert, .didTapDismissError):
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
