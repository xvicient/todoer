import Combine
import Common
import Entities
import Foundation
import Shared
import SwiftUI
import xRedux

// MARK: - Reduce

extension HomeReducer {
    @MainActor
    public func reduce(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action> {
        switch action {
        case .shared(let sharedAction):
            return sharedReducer.reduce(&state.shared, sharedAction).map { .shared($0) }

        case .onViewAppear:
            return onAppear(state: &state)

        case .onSceneActive:
            return onSceneActive(state: &state)

        case .didTapList(let uid):
            return onDidTapList(state: &state, uid: uid)

        case .didTapShareListButton(let uid):
            return onDidTapShareListButton(state: &state, uid: uid)

        case .fetchDataResult(let result):
            return onFetchDataResult(state: &state, result: result)

        case .addSharedListsResult(let result):
            return onAddSharedListsResult(state: &state, result: result)
        }
    }
}

// MARK: - Actions

@MainActor
fileprivate extension HomeReducer {
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        if state.shared.items.isEmpty {
            state.shared.viewState = .loading(true)
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

        state.shared.finishAdding()

        nonisolated(unsafe) let useCase = useCase
        return .task { send in
            await send(.addSharedListsResult(useCase.addSharedLists()))
        }
    }

    func onDidTapList(
        state: inout State,
        uid: String
    ) -> Effect<Action> {
        guard let index = state.shared.items.index(for: uid),
              let list = state.shared.items[safe: index]
        else {
            state.shared.viewState = .error()
            return .none
        }
        dependencies.coordinator?.push(.listItems(list))
        return .none
    }

    func onDidTapShareListButton(
        state: inout State,
        uid: String
    ) -> Effect<Action> {
        guard let index = state.shared.items.index(for: uid),
              let list = state.shared.items[safe: index]
        else {
            state.shared.viewState = .error()
            return .none
        }
        dependencies.coordinator?.present(sheet: .shareList(list))
        return .none
    }
}

// MARK: - Results

@MainActor
fileprivate extension HomeReducer {
    func onFetchDataResult(
        state: inout State,
        result: ActionResult<HomeData>
    ) -> Effect<Action> {
        switch result {
        case .success(let data):
            if case .loading = state.shared.viewState {
                state.shared.viewState = .idle
            }
            state.shared.items = data.lists
            state.invitations = data.invitations
        case .failure(let error):
            state.shared.viewState = .error(error.localizedDescription)
        }
        return .none
    }

    func onAddSharedListsResult(
        state: inout State,
        result: ActionResult<[UserList]>
    ) -> Effect<Action> {
        switch result {
        case .success(let lists):
            guard !lists.isEmpty else {
                return .none
            }
            state.shared.items.insert(contentsOf: lists, at: 0)
        case .failure:
            break
        }
        return .none
    }
}
