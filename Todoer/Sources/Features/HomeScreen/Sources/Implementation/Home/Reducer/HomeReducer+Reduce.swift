import Common
import xRedux

extension Home.Reducer {
    @MainActor
    public func reduce(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action> {

        switch (state.viewState, action) {
        case (.idle, .onViewAppear):
            return onAppear(
                state: &state
            )

        case (_, .onSceneActive):
            return onSceneActive(
                state: &state
            )

        case (.idle, .didTapList(let rowId)):
            return onDidTapList(
                state: &state,
                uid: rowId
            )
            
        case (.updating, .didTapSubmitListButton(let uid, let name)):
            return onDidTapSubmitListButton(
                state: &state,
                newListName: name,
                uid: uid
            )
            
        case (.updating, .didTapCancelButton):
            return onDidTapCancelButton(
                state: &state
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

        case (.updating, .didMoveList(let fromIndex, let toIndex)):
            return onDidMoveList(
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
            
        case (.idle, .didChangeActiveTab(let activeTab)),
            (.updating, .didChangeActiveTab(let activeTab)):
            return onDidChangeActiveTab(
                state: &state,
                activeTab: activeTab
            )
            
        case (.idle, .didUpdateSearchText(let text)):
            return onDidUpdateSearchText(
                state: &state,
                searchText: text
            )

        case (.loading, .addSharedListsResult(let result)),
            (.idle, .addSharedListsResult(let result)):
            return onAddSharedListsResult(
                state: &state,
                result: result
            )

        case (_, .fetchDataResult(let result)):
            return onFetchDataResult(
                state: &state,
                result: result
            )
            
        case (.updating, .addListResult(let result)):
            return onAddListResult(
                state: &state,
                result: result
            )
            
        case (.updating, .updateListResult(let result)):
            return onUpdateListResult(
                state: &state,
                result: result
            )

        case (.loading, .voidResult(let result)):
            return onVoidResult(
                state: &state,
                result: result
            )
            
        case (.updating, .moveListResult(let result)):
            return onMoveListResult(
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
