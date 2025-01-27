import Combine
import Application

// MARK: - View appear

extension Home.Reducer {
    
    @MainActor
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
