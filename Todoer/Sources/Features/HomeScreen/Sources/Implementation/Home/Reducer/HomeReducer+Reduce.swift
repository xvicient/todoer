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
        
        switch (state.screen.viewState, action) {
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
            return TDListScreenReducer.onDidChangeSearchFocus(
                state: &state.screen,
                isFocused: isFocused
            )

        case (.idle, .didChangeEditMode(let editMode)),
            (.adding, .didChangeEditMode(let editMode)),
            (.updating, .didChangeEditMode(let editMode)):
            return TDListScreenReducer.onDidChangeEditMode(
                state: &state.screen,
                editMode: editMode
            )

        case (.idle, .didChangeActiveTab(let activeTab)),
            (.adding, .didChangeActiveTab(let activeTab)),
            (.updating, .didChangeActiveTab(let activeTab)):
            switch activeTab {
            case .add:
                return addList(state: &state)
            case .sort:
                return sortLists(state: &state)
            default:
                return TDListScreenReducer.onDidChangeActiveTab(
                    state: &state.screen,
                    activeTab: activeTab
                )
            }
            
        case (.idle, .didUpdateSearchText(let text)):
            state.screen.searchText = text
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
            
        case (.updating, .moveListResult(.success)):
            return .none

        case (.updating, .moveListResult(.failure)):
            state.screen.viewState = .error(dismissAction: .didTapDismissError)
            return .none
            
        case (.alert, .didTapDismissError):
            state.screen.viewState = .idle
            return .none
            
        default:
            Logger.log(
                "No matching ViewState: \(state.screen.viewState.rawValue) and Action: \(action.rawValue)"
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
            state.screen.viewState = .loading(true)
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

        TDListScreenReducer.didFinishAdding(state: &state.screen)

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
            state.screen.viewState = .error(dismissAction: .didTapDismissError)
            return .none
        }
        dependencies.coordinator?.push(.listItems(list))
        return .none
    }

    func onDidTapToggleListButton(
        state: inout State,
        uid: String
    ) -> Effect<Action> {
        guard let index = state.lists.index(for: uid),
              state.lists[safe: index] != nil
        else {
            state.screen.viewState = .error(dismissAction: .didTapDismissError)
            return .none
        }
        state.screen.viewState = .loading(false)
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
            state.screen.viewState = .error(dismissAction: .didTapDismissError)
            return .none
        }
        state.screen.viewState = .loading(false)
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
            state.screen.viewState = .error(dismissAction: .didTapDismissError)
            return .none
        }
        dependencies.coordinator?.present(sheet: .shareList(list))
        
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
            activeTab: state.screen.activeTab
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
    
    func addList(
        state: inout State
    ) -> Effect<Action> {
        switch state.screen.viewState {
        case .idle:
            state.screen.viewState = .adding
            state.screen.activeTab = .add(true)
            state.screen.isSearchFocused = false
            return .none
        case .adding:
            TDListScreenReducer.didFinishAdding(state: &state.screen)
            return .none
        default:
            return .none
        }
    }

    func sortLists(
        state: inout State
    ) -> Effect<Action> {
        state.screen.viewState = .loading(false)
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
}

// MARK: - Results

fileprivate extension HomeReducer {

    func onFetchDataResult(
        state: inout State,
        result: ActionResult<HomeData>
    ) -> Effect<Action> {
        switch result {
        case .success(let data):
            if case .loading = state.screen.viewState { state.screen.viewState = .idle }
            state.lists = data.lists
            state.invitations = data.invitations
            return .none
        case .failure(let error):
            state.screen.viewState = .error(error.localizedDescription, dismissAction: .didTapDismissError)
        }
        return .none
    }

    func onAddListResult(
        state: inout State,
        result: ActionResult<UserList>
    ) -> Effect<Action> {
        TDListScreenReducer.didFinishAdding(state: &state.screen)
        switch result {
        case .success(let list):
            state.lists.insert(list, at: 0)
            state.screen.viewState = .idle
        case .failure(let error):
            state.screen.viewState = .error(error.localizedDescription, dismissAction: .didTapDismissError)
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
                state.screen.viewState = .error(dismissAction: .didTapDismissError)
                return .none
            }
            state.lists.replace(list, at: index)
            state.screen.viewState = .updating
        case .failure(let error):
            state.screen.viewState = .error(error.localizedDescription, dismissAction: .didTapDismissError)
        }
        return .none
    }

    func onVoidResult(
        state: inout State,
        result: ActionResult<EquatableVoid>
    ) -> Effect<Action> {
        switch result {
        case .success:
            state.screen.viewState = .idle
        case .failure:
            state.screen.viewState = .error(dismissAction: .didTapDismissError)
        }
        return .none
    }
}
