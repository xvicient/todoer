import Combine
import xRedux

// MARK: - View appear

extension Home.Reducer {

    @MainActor
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading
        if state.viewModel.lists.isEmpty {
            dependencies.coordinator.showLoading(true)
        }

        return .publish(
            useCase.fetchHomeData()
                .handleEvents(receiveOutput: { _ in
                    dependencies.coordinator.showLoading(false)
                }, receiveCancel: {
                    dependencies.coordinator.showLoading(false)
                })
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

        if state.viewState == .addingList {
            _ = onDidTapCancelAddListButton(state: &state)
        }

        if case let .editingList(uid) = state.viewState {
            _ = onDidTapCancelEditListButton(state: &state, uid: uid)
        }

        state.viewState = .loading

        return .task { send in
            await send(
                .addSharedListsResult(
                    useCase.addSharedLists()
                )
            )
        }
    }
}
