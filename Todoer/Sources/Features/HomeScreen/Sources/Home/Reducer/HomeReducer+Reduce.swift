import Application
import Common

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
            
        case (.loading, .addSharedListsResult(let result)):
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
