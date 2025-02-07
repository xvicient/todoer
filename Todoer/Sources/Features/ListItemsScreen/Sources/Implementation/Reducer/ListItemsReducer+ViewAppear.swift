import Combine
import xRedux

// MARK: - Reducer view appear

@MainActor
extension ListItems.Reducer {
	func onAppear(
		state: inout State
	) -> Effect<Action> {
		state.viewState = .loading
		return .publish(
            dependencies.useCase.fetchItems(
				listId: dependencies.list.documentId
			)
			.map { .fetchItemsResult(.success($0)) }
			.catch { Just(.fetchItemsResult(.failure($0))) }
			.eraseToAnyPublisher()
		)
	}
}
