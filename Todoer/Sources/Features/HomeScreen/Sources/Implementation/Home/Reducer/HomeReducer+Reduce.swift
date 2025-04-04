import Common
import xRedux
import Foundation
import ThemeComponents
import SwiftUI
import Entities
import Combine

// MARK: - Reduce

extension HomeReducer {
    @MainActor
    public func reduce(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action> {
        
        switch (state.viewState, action) {
        case (.loading, .onViewAppear),
            (.idle, .onViewAppear):
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
            
        case (.updating, .didTapSubmitListButton(let uid, let name)),
            (.adding, .didTapSubmitListButton(let uid, let name)):
            return onDidTapSubmitListButton(
                state: &state,
                newListName: name,
                uid: uid
            )
            
        case (.adding, .didTapCancelButton):
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
            
        case (_, .didChangeSearchFocus(let isFocused)):
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
            state.searchText = text
            return .none
            
        case (.loading, .addSharedListsResult(.success(let lists))),
            (.idle, .addSharedListsResult(.success(let lists))):
            guard !lists.isEmpty else { return .none }
            state.lists.insert(contentsOf: lists, at: 0)
            return .none
            
        case (_, .fetchDataResult(let result)):
            return onFetchDataResult(
                state: &state,
                result: result
            )
            
        case (.adding, .addListResult(let result)):
            return onAddListResult(
                state: &state,
                result: result
            )
            
        case (.updating, .updateListResult(let result)):
            return onUpdateListResult(
                state: &state,
                result: result
            )
            
        case (.loading, .voidResult(let result)),
            (.idle, .voidResult(let result)):
            return onVoidResult(
                state: &state,
                result: result
            )
            
        case (.updating, .moveListResult(.failure)):
            state.viewState = .error()
            return .none
            
        case (.alert, .didTapDismissError):
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

// MARK: - Actions

fileprivate extension HomeReducer {
    
    @MainActor
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        if state.lists.isEmpty {
            state.viewState = .loading(true)
        }

        return .publish(
            useCase.fetchHomeData()
                .map { .fetchDataResult(.success($0)) }
                .catch { Just(.fetchDataResult(.failure($0))) }
                .eraseToAnyPublisher()
        )
    }

    func onSceneActive(
        state: inout State
    ) -> Effect<Action> {
        guard useCase.sharedListsCount > 0 else {
            return .none
        }

        _ = onDidTapCancelButton(state: &state)

        return .task { send in
            await send(
                .addSharedListsResult(
                    useCase.addSharedLists()
                )
            )
        }
    }
    
    @MainActor
    func onDidTapList(
        state: inout State,
        uid: String
    ) -> Effect<Action> {
        guard let index = state.lists.index(for: uid),
              let list = state.lists[safe: index]
        else {
            state.viewState = .error()
            return .none
        }
        dependencies.coordinator.push(.listItems(list))
        return .none
    }
    
    @discardableResult
    func onDidTapCancelButton(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .idle        
        return .none
    }
    
    func onDidTapToggleListButton(
        state: inout State,
        uid: String
    ) -> Effect<Action> {
        guard let index = state.lists.index(for: uid),
              state.lists[safe: index] != nil
        else {
            state.viewState = .error()
            return .none
        }
        state.viewState = .loading(false)
        state.lists[index].done.toggle()
        let list = state.lists[index]
        
        return .task { send in
            await send(
                .voidResult(
                    useCase.toggleList(
                        list: list
                    )
                )
            )
        }
    }
    
    func onDidTapDeleteListButton(
        state: inout State,
        uid: String
    ) -> Effect<Action> {
        guard let index = state.lists.index(for: uid),
              let list = state.lists[safe: index] else {
            state.viewState = .error()
            return .none
        }
        state.viewState = .loading(false)
        state.lists.remove(at: index)
        
        return .task { send in
            await send(
                .voidResult(
                    useCase.deleteList(list.id)
                )
            )
        }
    }
    
    func onDidTapSubmitListButton(
        state: inout State,
        newListName: String,
        uid: String?
    ) -> Effect<Action> {
        if let uid {
            guard let index = state.lists.index(for: uid) else {
                return .none
            }
            var list = state.lists[index]
            list.name = newListName
            
            return .task { send in
                await send(
                    .updateListResult(
                        useCase.updateList(
                            list: list
                        )
                    )
                )
            }
        } else {
            return .task { send in
                await send(
                    .addListResult(
                        useCase.addList(
                            name: newListName
                        )
                    )
                )
            }
        }
    }
    
    @MainActor
    func onDidTapShareListButton(
        state: inout State,
        uid: String
    ) -> Effect<Action> {
        guard let index = state.lists.index(for: uid),
              let list = state.lists[safe: index]
        else {
            state.viewState = .error()
            return .none
        }
        dependencies.coordinator.present(sheet: .shareList(list))
        
        return .none
    }
    
    func onDidMoveList(
        state: inout State,
        fromIndex: IndexSet,
        toIndex: Int
    ) -> Effect<Action> {
        let lists = state.lists.move(
            fromIndex: fromIndex,
            toIndex: toIndex,
            isCompleted: state.activeTab.isCompleted
        )
        
        return .task { send in
            await send(
                .moveListResult(
                    useCase.sortLists(
                        lists: lists
                    )
                )
            )
        }
    }
    
    func onDidChangeSearchFocus(
        state: inout State,
        isFocused: Bool
    ) -> Effect<Action> {
        state.isSearchFocused = isFocused
        
        if isFocused {
            onDidTapCancelButton(state: &state)
            
            if state.editMode.isEditing {
                state.editMode = .inactive
                state.viewState = state.editMode.viewState
            }
        }
        
        return .none
    }
    
    func onDidChangeEditMode(
        state: inout State,
        editMode: EditMode
    ) -> Effect<Action> {
        if !state.editMode.isEditing && state.viewState == .updating {
            onDidTapCancelButton(state: &state)
        }
        state.isSearchFocused = false
        state.editMode = editMode
        state.viewState = editMode.viewState
        return .none
    }
    
    func onDidChangeActiveTab(
        state: inout State,
        activeTab: TDListTab
    ) -> Effect<Action> {
        
        /// Canceling edit mode if active if the user wants to add an item
        if state.editMode == .active {
            state.editMode = .inactive
        }
        
        switch activeTab {
        case .add:
            return addList(state: &state)
        case .sort:
            return sortLists(state: &state)
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
    
    func addList(
        state: inout State
    ) -> Effect<Action> {
        guard state.viewState == .idle else {
            return .none
        }
        
        state.activeTab = .all
        state.isSearchFocused = false
        state.viewState = .adding
        
        return .none
    }
    
    func sortLists(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading(false)
        state.lists.sorted()
        
        let lists = state.lists
        
        return .task { send in
            await send(
                .voidResult(
                    useCase.sortLists(
                        lists: lists
                    )
                )
            )
        }
    }
    
    func performAction(
        state: inout State,
        activeTab: TDListTab
    ) -> Effect<Action> {
        guard state.activeTab != activeTab else { return .none }
        state.activeTab = activeTab
        state.viewState = .idle
        return .none
    }
}

// MARK: - Results

fileprivate extension HomeReducer {

    func onFetchDataResult(
        state: inout State,
        result: ActionResult<HomeData>
    ) -> Effect<Action> {
        switch result {
        case .success(let data):
            if case .loading = state.viewState { state.viewState = .idle }
            state.lists = data.lists
            state.invitations = data.invitations
            return .none
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }
    
    func onAddListResult(
        state: inout State,
        result: ActionResult<UserList>
    ) -> Effect<Action> {
        switch result {
        case .success(let list):
            state.lists.insert(list, at: 0)
            state.viewState = .idle
        case .failure(let error):
            state.viewState = .error(error.localizedDescription)
        }
        return .none
    }
    
    func onUpdateListResult(
        state: inout State,
        result: ActionResult<UserList>
    ) -> Effect<Action> {
        switch result {
        case .success(let list):
            guard let index = state.lists.firstIndex(where: { $0.id == list.id }) else {
                state.viewState = .error()
                return .none
            }
            state.lists.replace(list, at: index)
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

extension EditMode {
    fileprivate var viewState: HomeReducer.ViewState {
        switch self {
        case .active:
                .updating
        default:
                .idle
        }
    }
}
