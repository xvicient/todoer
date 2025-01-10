import Combine
import Application

// MARK: - View appear

@MainActor
extension Home.Reducer {
	func onAppear(
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
		return .task { send in
			await send(
				.getPhotoUrlResult(
					dependencies.useCase.getPhotoUrl()
				)
			)
		}
	}
}
