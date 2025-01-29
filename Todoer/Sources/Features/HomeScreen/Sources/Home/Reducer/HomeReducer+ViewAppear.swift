import Combine
import Application
import Foundation

// MARK: - View appear

extension Home.Reducer {
    
    @MainActor
	func onAppear(
		state: inout State
	) -> Effect<Action> {
		state.viewState = .loading
		return .publish(
			useCase.fetchHomeData()
				.map { .fetchDataResult(.success($0)) }
				.catch { Just(.fetchDataResult(.failure($0))) }
				.eraseToAnyPublisher()
		)
	}
    
    func onActive(
        state: inout State
    ) -> Effect<Action> {
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
