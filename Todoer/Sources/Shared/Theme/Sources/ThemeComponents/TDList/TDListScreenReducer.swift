import SwiftUI
import xRedux

public enum TDListScreenReducer {

    public static func onDidChangeSearchFocus<Action>(
        state: inout TDListScreenState<Action>,
        isFocused: Bool
    ) -> Effect<Action> {
        state.isSearchFocused = isFocused

        if isFocused {
            didFinishAdding(state: &state)

            if state.editMode.isEditing {
                state.editMode = .inactive
                state.viewState = state.editMode.tdViewState()
            }
        }

        return .none
    }

    public static func onDidChangeEditMode<Action>(
        state: inout TDListScreenState<Action>,
        editMode: EditMode
    ) -> Effect<Action> {
        if !state.editMode.isEditing && state.viewState == .adding {
            didFinishAdding(state: &state)
        }
        state.isSearchFocused = false
        state.editMode = editMode
        state.viewState = editMode.tdViewState()
        return .none
    }

    /// Handles the shared filter tabs (`.edit`/`.all`/`.done`/`.todo`). `.add`/`.sort`
    /// need the full feature state (the list of rows and its use case), so callers
    /// handle those two cases themselves before falling back to this helper.
    public static func onDidChangeActiveTab<Action>(
        state: inout TDListScreenState<Action>,
        activeTab: TDListTabItem
    ) -> Effect<Action> {
        if state.editMode == .active {
            state.editMode = .inactive
        }

        switch activeTab {
        case .add, .sort:
            return .none
        case .edit:
            /// Handled in onDidChangeEditMode since we're using a EditButton
            return .none
        case .all:
            return performAction(state: &state, activeTab: .all)
        case .done:
            return performAction(state: &state, activeTab: .done)
        case .todo:
            return performAction(state: &state, activeTab: .todo)
        }
    }

    public static func didFinishAdding<Action>(
        state: inout TDListScreenState<Action>
    ) {
        state.viewState = .idle
        state.activeTab = .add(false)
        state.isSearchFocused = false
    }

    public static func performAction<Action>(
        state: inout TDListScreenState<Action>,
        activeTab: TDListTabItem
    ) -> Effect<Action> {
        guard state.activeTab != activeTab else {
            return .none
        }
        state.activeTab = activeTab
        state.viewState = .idle
        return .none
    }
}

public extension EditMode {
    func tdViewState<Action: Equatable & Sendable>() -> TDListViewState<Action> {
        switch self {
        case .active:
            .updating
        default:
            .idle
        }
    }
}
