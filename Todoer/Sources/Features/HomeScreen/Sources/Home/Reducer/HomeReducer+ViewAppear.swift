import Combine
import Application

// MARK: - View appear

/// Extension containing view appearance handling for the Home Reducer
extension Home.Reducer {
    /// Handles the view's appearance by initiating data fetching
    /// - Parameter state: Current state to modify
    /// - Returns: Effect that fetches home data
    func onAppear(
        state: inout State
    ) -> Effect<Action> {
        state.viewState = .loading
        return .publish(
            useCase.fetchData()
                .map { .fetchDataResult(.success($0)) }
                .catch { Just(.fetchDataResult(.failure($0))) }
                .eraseToAnyPublisher()
        )
    }
}
