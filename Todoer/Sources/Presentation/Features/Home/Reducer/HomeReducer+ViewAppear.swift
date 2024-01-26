import Combine

// MARK: - View appear

@MainActor
internal extension Home.Reducer {
    func onViewAppear(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading
        return .publish(
            dependencies.useCase.fetchData()
                .map { .fetchDataResult(.success($0)) }
                .catch { Just(.fetchDataResult(.failure($0))) }
                .eraseToAnyPublisher()
            )
    }
    
    func onProfilePhotoAppear(
        state: inout State
    ) -> Effect<Action> {
        return .task(Task {
            .getPhotoUrlResult(
                await dependencies.useCase.getPhotoUrl()
            )
        })
    }
}
