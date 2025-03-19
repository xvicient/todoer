import Combine
import xRedux

// MARK: - View appear

extension Home.Reducer {

    @MainActor
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        if state.viewModel.lists.isEmpty {
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
        
        state.viewState = .loading(true)

        _ = onDidTapCancelButton(state: &state)

        return .task { send in
            await send(
                .addSharedListsResult(
                    useCase.addSharedLists()
                )
            )
        }
    }
}
