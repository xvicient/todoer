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
            
        case (.updating, .didTapSubmitItemButton(let uid, let newItemName)):
            return onDidTapSubmitItemButton(
                state: &state,
                newItemName: newItemName,
                uid: uid
            )
            
        case (.updating, .didTapCancelButton):
            return onDidTapCancelButton(
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
            
        case (.updating, .didMoveItem(let fromIndex, let toIndex)):
            return onDidMoveItem(
                state: &state,
                fromIndex: fromIndex,
                toIndex: toIndex
            )
            
        case (.updating, .didChangeSearchFocus(let isFocused)):
            return onDidChangeSearchFocus(
                state: &state,
                isFocused: isFocused
            )
            
        case (.idle, .didChangeEditMode(let editMode)),
            (.updating, .didChangeEditMode(let editMode)):
            return onDidChangeEditMode(
                state: &state,
                editMode: editMode
            )
            
        case (.idle, .didChangeActiveTab(let activeTab)):
            return onDidChangeActiveTab(
                state: &state,
                activeTab: activeTab
            )
            
        case (.idle, .didUpdateSearchText(let text)):
            return onDidUpdateSearchText(
                state: &state,
                searchText: text
            )

        case (_, .fetchItemsResult(let result)):
            return onFetchItemsResult(
                state: &state,
                result: result
            )

        case (.updating, .addItemResult(let result)):
            return onAddItemResult(
                state: &state,
                result: result
            )
            
        case (.updating, .updateItemResult(let result)):
            return onUpdateItemResult(
                state: &state,
                result: result
            )
            
        case (.loading, .voidResult(let result)),
            (.updating, .voidResult(let result)):
            return onVoidResult(
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
