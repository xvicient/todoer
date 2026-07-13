import Combine
import Common
import Entities
import Foundation
import Shared
import xRedux

// MARK: - Reduce

extension ListItemsReducer {
    @MainActor
    func reduce(
        _ state: inout State,
        _ action: Action
    ) -> Effect<Action> {
        switch action {
        case .shared(let sharedAction):
            return sharedReducer.reduce(&state.shared, sharedAction).map { .shared($0) }

        case .onAppear:
            return onAppear(state: &state)

        case .fetchItemsResult(let result):
            return onFetchItemsResult(state: &state, result: result)
        }
    }
}

// MARK: - Actions

@MainActor
fileprivate extension ListItemsReducer {
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        state.shared.viewState = .loading(true)
        return .publish(
            dependencies.useCase.fetchItems(
                listId: dependencies.list.id
            )
            .map { .fetchItemsResult(.success($0)) }
            .catch { Just(.fetchItemsResult(.failure($0))) }
            .eraseToAnyPublisher()
        )
    }

    func onFetchItemsResult(
        state: inout State,
        result: ActionResult<[Item]>
    ) -> Effect<Action> {
        switch result {
        case .success(let items):
            if case .loading = state.shared.viewState {
                state.shared.viewState = .idle
            }
            state.shared.items = items
        case .failure(let error):
            state.shared.viewState = .error(error.localizedDescription)
        }
        return .none
    }
}
