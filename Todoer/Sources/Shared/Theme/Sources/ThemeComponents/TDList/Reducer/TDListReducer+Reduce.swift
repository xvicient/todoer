import Combine
import Common
import Foundation
import SwiftUI
import xRedux

// MARK: - Reduce

extension TDListReducer {
    @MainActor
    public func reduce(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action> {
        switch (state.viewState, action) {
        case (.updating, .didTapSubmitButton(let uid, let name)),
            (.adding, .didTapSubmitButton(let uid, let name)):
            return onDidTapSubmit(state: &state, name: name, uid: uid)

        case (.idle, .didTapToggleButton(let rowId)):
            return onDidTapToggle(state: &state, uid: rowId)

        case (.idle, .didTapDeleteButton(let rowId)):
            return onDidTapDelete(state: &state, uid: rowId)

        case (.updating, .didMove(let fromIndex, let toIndex)):
            return onDidMove(state: &state, fromIndex: fromIndex, toIndex: toIndex)

        case (_, .didChangeSearchFocus(let isFocused)):
            return onDidChangeSearchFocus(state: &state, isFocused: isFocused)

        case (.idle, .didChangeEditMode(let editMode)),
            (.adding, .didChangeEditMode(let editMode)),
            (.updating, .didChangeEditMode(let editMode)):
            return onDidChangeEditMode(state: &state, editMode: editMode)

        case (.idle, .didChangeActiveTab(let activeTab)),
            (.adding, .didChangeActiveTab(let activeTab)),
            (.updating, .didChangeActiveTab(let activeTab)):
            return onDidChangeActiveTab(state: &state, activeTab: activeTab)

        case (.idle, .didUpdateSearchText(let text)):
            state.searchText = text
            return .none

        case (.adding, .addResult(let result)):
            return onAddResult(state: &state, result: result)

        case (.updating, .updateResult(let result)):
            return onUpdateResult(state: &state, result: result)

        case (.loading, .voidResult(let result)),
            (.idle, .voidResult(let result)):
            return onVoidResult(state: &state, result: result)

        case (.updating, .moveResult(.success)):
            return .none

        case (.updating, .moveResult(.failure)):
            state.viewState = .error()
            return .none

        case (.error, .didTapDismissError):
            state.viewState = .idle
            return .none

        default:
            Logger.log(
                "No matching ViewState: \(state.viewState.rawValue) and Action: \(action.rawValue)"
            )
            return .none
        }
    }
}

// MARK: - User actions

fileprivate extension TDListReducer {
    func onDidTapSubmit(
        state: inout State,
        name: String,
        uid: String?
    ) -> Effect<Action> {
        let useCase = useCase
        if let uid {
            guard let index = state.items.index(for: uid) else {
                return .none
            }
            var element = state.items[index]
            element.name = name
            return .task { send in
                await send(.updateResult(useCase.update(element)))
            }
        } else {
            return .task { send in
                await send(.addResult(useCase.add(name: name)))
            }
        }
    }

    func onDidTapToggle(
        state: inout State,
        uid: String
    ) -> Effect<Action> {
        guard let index = state.items.index(for: uid),
              state.items[safe: index] != nil
        else {
            state.viewState = .error()
            return .none
        }
        state.viewState = .loading(false)
        state.items[index].done.toggle()

        let element = state.items[index]
        let elements = state.items
        let useCase = useCase

        return .task { send in
            await send(.voidResult(useCase.toggle(element, in: elements)))
        }
    }

    func onDidTapDelete(
        state: inout State,
        uid: String
    ) -> Effect<Action> {
        guard let index = state.items.index(for: uid),
              let element = state.items[safe: index]
        else {
            state.viewState = .error()
            return .none
        }
        state.viewState = .loading(false)
        state.items.remove(at: index)

        let useCase = useCase

        return .task { send in
            await send(.voidResult(useCase.delete(element)))
        }
    }

    func onDidMove(
        state: inout State,
        fromIndex: IndexSet,
        toIndex: Int
    ) -> Effect<Action> {
        let elements = state.items.move(
            fromIndex: fromIndex,
            toIndex: toIndex,
            activeTab: state.activeTab
        )
        let useCase = useCase

        return .task { send in
            await send(.moveResult(useCase.sort(elements)))
        }
    }

    func onDidChangeSearchFocus(
        state: inout State,
        isFocused: Bool
    ) -> Effect<Action> {
        state.isSearchFocused = isFocused

        if isFocused {
            didFinishAdding(state: &state)

            if state.editMode.isEditing {
                state.editMode = .inactive
                state.viewState = state.editMode.tdListViewState
            }
        }

        return .none
    }

    func onDidChangeEditMode(
        state: inout State,
        editMode: EditMode
    ) -> Effect<Action> {
        if !state.editMode.isEditing && state.viewState == .adding {
            didFinishAdding(state: &state)
        }
        state.isSearchFocused = false
        state.editMode = editMode
        state.viewState = editMode.tdListViewState
        return .none
    }

    func onDidChangeActiveTab(
        state: inout State,
        activeTab: TDListTabItem
    ) -> Effect<Action> {
        /// Canceling edit mode if active if the user wants to add an item
        if state.editMode == .active {
            state.editMode = .inactive
        }

        switch activeTab {
        case .add:
            return addRow(state: &state)
        case .sort:
            return sortRows(state: &state)
        case .edit:
            /// Handled in onDidChangeEditMode since we're using an EditButton
            return .none
        case .all:
            return performAction(state: &state, activeTab: .all)
        case .done:
            return performAction(state: &state, activeTab: .done)
        case .todo:
            return performAction(state: &state, activeTab: .todo)
        }
    }

    func didFinishAdding(
        state: inout State
    ) {
        state.finishAdding()
    }

    func addRow(
        state: inout State
    ) -> Effect<Action> {
        switch state.viewState {
        case .idle:
            state.viewState = .adding
            state.activeTab = .add(true)
            state.isSearchFocused = false
            return .none
        case .adding:
            didFinishAdding(state: &state)
            return .none
        default:
            return .none
        }
    }

    func sortRows(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading(false)
        state.items.sorted()

        let elements = state.items
        let useCase = useCase

        return .task { send in
            await send(.voidResult(useCase.sort(elements)))
        }
    }

    func performAction(
        state: inout State,
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

// MARK: - Results

fileprivate extension TDListReducer {
    func onAddResult(
        state: inout State,
        result: ActionResult<Element>
    ) -> Effect<Action> {
        didFinishAdding(state: &state)
        switch result {
        case .success(let element):
            state.items.insert(element, at: 0)
            state.viewState = .idle
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }

    func onUpdateResult(
        state: inout State,
        result: ActionResult<Element>
    ) -> Effect<Action> {
        switch result {
        case .success(let element):
            guard let index = state.items.firstIndex(where: { $0.id == element.id }) else {
                state.viewState = .error()
                return .none
            }
            state.items.replace(element, at: index)
            state.viewState = .updating
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }

    func onVoidResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.viewState = .idle
        case .failure:
            state.viewState = .error()
        }
        return .none
    }
}
