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
            
        case (.idle, .didTapAddListButton):
            return onDidTapAddListButton(
                state: &state
            )
            
        case (.updating, .didTapSubmitListButton(let name)):
            return onDidTapSubmitListButton(
                state: &state,
                newListName: name
            )
            
        case (.updating, .didTapCancelButton):
            return onDidTapCancelButton(
                state: &state
            )
            
        case (.idle, .didTapEditButton):
            return onDidTapEditButton(
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

        case (.idle, .didMoveList(let fromIndex, let toIndex, let isCompleted)):
            return onDidMoveList(
                state: &state,
                fromIndex: fromIndex,
                toIndex: toIndex,
                isCompleted: isCompleted
            )

        case (.idle, .didTapAutoSortLists):
            return onDidTapAutoSortLists(
                state: &state
            )
            
        case (.updating, .didChangeSearchFocus(let isFocused)):
            return onDidChangeSearchFocus(
                state: &state,
                isFocused: isFocused
            )
            
        case (.idle, .didChangeEditMode(let editMode)):
            return onDidChangeEditMode(
                state: &state,
                editMode: editMode
            )

        case (.loading, .addSharedListsResult(let result)),
            (.idle, .addSharedListsResult(let result)):
            return onAddSharedListsResult(
                state: &state,
                result: result
            )

        case (.idle, .fetchDataResult(let result)),
            (.loading, .fetchDataResult(let result)):
            return onFetchDataResult(
                state: &state,
                result: result
            )
            
        case (.loading, .addListResult(let result)):
            return onAddListResult(
                state: &state,
                result: result
            )

        case (.loading, .toggleListResult(let result)):
            return onResult(
                state: &state,
                result: result
            )

        case (.loading, .deleteListResult(let result)):
            return onResult(
                state: &state,
                result: result
            )

        case (.loading, .moveListsResult(let result)):
            return onResult(
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
